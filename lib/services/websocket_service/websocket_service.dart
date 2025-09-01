import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class WebSocketService {
  static const String _baseWsUrl = 'ws://192.168.29.253:8000/ws';

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _connectionTimeoutTimer;

  bool _isConnected = false;
  bool _isAuthenticated = false;
  bool _shouldReconnect = true;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);

  // ⭐ FIX: Réduire le timeout de connexion initial
  static const Duration _connectionTimeout = Duration(seconds: 8);

  String? _lastToken;

  // Getters
  bool get isConnected => _isConnected && _isAuthenticated;
  Stream<Map<String, dynamic>> get messageStream =>
      _messageController?.stream ?? Stream.empty();

  WebSocketService() {
    _messageController = StreamController<Map<String, dynamic>>.broadcast();
  }

  Future<void> connect(String accessToken) async {
    log(
      '🎯 DEBUT connect() - isConnecting: $_isConnecting, isConnected: $_isConnected, isAuthenticated: $_isAuthenticated',
    );

    if (_isConnecting) {
      log('WebSocket déjà en cours de connexion, attente...');
      return;
    }

    if (_isConnected && _isAuthenticated) {
      log('WebSocket déjà connecté et authentifié');
      return;
    }

    _isConnecting = true;
    _lastToken = accessToken;

    try {
      log('🔄 Connexion WebSocket vers: $_baseWsUrl/wallet/');

      // Nettoyer les anciennes connexions
      await _cleanupConnection();

      // ⭐ FIX: Vérifier la connectivité réseau AVANT de tenter la connexion
      if (!await _checkNetworkConnectivity()) {
        throw SocketException('No network connectivity');
      }

      final wsUrl = '$_baseWsUrl/wallet/?token=$accessToken';
      log('🌐 Création WebSocketChannel vers: $wsUrl');

      // ⭐ FIX: Créer le WebSocketChannel avec gestion d'erreur immédiate
      try {
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl), protocols: null);
        log('✅ WebSocketChannel créé');
      } catch (e) {
        log('❌ Erreur création WebSocketChannel: $e');
        _isConnecting = false;
        throw e;
      }

      // ⭐ FIX: Timeout plus court et gestion plus robuste
      _startConnectionTimeout(timeoutDuration: _connectionTimeout);

      // ⭐ FIX: Configuration des listeners avec gestion d'erreur améliorée
      log('👂 Configuration des listeners...');
      _channel!.stream
          .timeout(
            Duration(seconds: 10), // Timeout plus court pour le stream
            onTimeout: (sink) {
              log('❌ Timeout stream WebSocket');
              sink.addError('WebSocket stream timeout');
              sink.close();
            },
          )
          .listen(
            _onMessage,
            onError: _onError,
            onDone: _onDisconnected,
            cancelOnError: false,
          );
      log('✅ Listeners configurés');

      // ⭐ FIX: Attendre un court instant pour voir si la connexion se fait
      await Future.delayed(Duration(milliseconds: 500));

      // Si toujours pas connecté après 500ms, il y a probablement un problème
      if (!_isConnected && !_isAuthenticated) {
        log('⚠️ Aucune réponse du serveur après 500ms');
      }
    } catch (e) {
      log('❌ Erreur connexion WebSocket: $e');
      _isConnecting = false;
      _connectionTimeoutTimer?.cancel();

      // ⭐ FIX: Gestion spécifique des erreurs réseau
      if (e is SocketException ||
          e.toString().contains('Connection timed out') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        log(
          '🚫 Erreur de réseau détectée - programmation reconnexion différée',
        );
        _handleNetworkError();
      } else {
        _scheduleReconnect();
      }
    }
  }

  // ⭐ FIX: Nouvelle méthode pour vérifier la connectivité réseau
  Future<bool> _checkNetworkConnectivity() async {
    try {
      // Test simple avec le serveur local d'abord
      final socket = await Socket.connect(
        '192.168.29.253',
        8000,
        timeout: Duration(seconds: 3),
      );
      await socket.close();
      log('✅ Connectivité serveur local OK');
      return true;
    } catch (e) {
      log('❌ Pas de connectivité serveur local: $e');

      // Test de connectivité internet générale
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(Duration(seconds: 3));
        if (result.isNotEmpty) {
          log('✅ Internet OK mais serveur local inaccessible');
          return false; // Internet OK mais pas le serveur local
        }
      } catch (_) {
        log('❌ Pas d\'internet du tout');
      }
      return false;
    }
  }

  void _startConnectionTimeout({
    Duration timeoutDuration = const Duration(seconds: 8),
  }) {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(timeoutDuration, () {
      log(
        '⏰ TIMEOUT! isAuthenticated: $_isAuthenticated, isConnected: $_isConnected, isConnecting: $_isConnecting',
      );

      if (!_isAuthenticated && !_isConnected) {
        log('❌ Timeout de connexion WebSocket - aucune connexion établie');
        _onError('Connection timeout - no connection established');
      } else if (_isConnected && !_isAuthenticated) {
        log(
          '🔧 Connexion établie mais pas marquée comme authentifiée, correction...',
        );
        _handleAuthenticated();
      } else {
        log('✅ Timeout ignoré - connexion déjà opérationnelle');
      }
    });
  }

  void _onMessage(dynamic message) {
    try {
      log('📨 Message WebSocket reçu (type: ${message.runtimeType}): $message');

      if (message is String) {
        // ⭐ FIX: Gestion des messages de statut simples
        switch (message.toLowerCase().trim()) {
          case 'connected':
            log('🔗 Message "connected" reçu');
            _handleConnectionEstablished();
            _handleAuthenticated();
            break;
          case 'authenticated':
            log('🔐 Message "authenticated" reçu');
            _handleAuthenticated();
            break;
          case 'disconnected':
            log('🔌 Message "disconnected" reçu');
            _onDisconnected();
            return;
          case 'ping':
            log('🏓 Ping reçu, envoi pong');
            _sendMessage({'type': 'pong'});
            return;
          default:
            // Essayer de parser comme JSON
            try {
              final data = jsonDecode(message);
              log('✅ JSON parsé avec succès: $data');
              _handleJsonMessage(data);
            } catch (e) {
              log('⚠️ Message WebSocket non-JSON: "$message"');
              // ⭐ FIX: Si on reçoit des données mais qu'on n'est pas connecté,
              // marquer comme connecté/authentifié
              if (!_isConnected || !_isAuthenticated) {
                log('🔧 Auto-correction: marquage connexion/auth comme OK');
                _handleConnectionEstablished();
                _handleAuthenticated();
              }
            }
        }
      } else if (message is Map<String, dynamic>) {
        log('📊 Traitement message Map: $message');
        _handleJsonMessage(message);
      }
    } catch (e) {
      log('❌ Erreur parsing message WebSocket: $e');
    }
  }

  void _handleConnectionEstablished() {
    if (!_isConnected) {
      _isConnected = true;
      log('✅ Connexion WebSocket marquée comme établie');
    }
  }

  void _handleAuthenticated() {
    log(
      '🔐 DEBUT _handleAuthenticated() - isAuthenticated: $_isAuthenticated, isConnecting: $_isConnecting',
    );

    if (!_isAuthenticated) {
      _isAuthenticated = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionTimeoutTimer?.cancel();

      log('✅ Authentification marquée comme réussie');

      // Démarrer le ping
      _startPing();

      // Notifier la connexion réussie
      _messageController?.add({
        'type': 'connected',
        'message': 'WebSocket connecté et authentifié avec succès',
      });

      log('🎉 WebSocket complètement opérationnel!');
    }
  }

  void _handleJsonMessage(Map<String, dynamic> data) {
    final type = data['type']?.toString().toLowerCase();

    if (type == 'connection_established' || type == 'connected') {
      _handleConnectionEstablished();
      if (type == 'connection_established') {
        _handleAuthenticated();
      }
      return;
    }

    if (type == 'authenticated' || type == 'authentication_success') {
      _handleAuthenticated();
      return;
    }

    if (type == 'authentication_failed' || type == 'auth_error') {
      log('🔐 Échec authentification WebSocket: ${data['message']}');
      _isAuthenticated = false;
      _messageController?.add({
        'type': 'auth_failed',
        'message': data['message'] ?? 'Authentification échouée',
      });
      _scheduleReconnect();
      return;
    }

    // Traitement des messages métier
    switch (type) {
      case 'wallet_update':
        _handleWalletUpdate(data);
        break;
      case 'transaction_created':
      case 'new_transaction':
        _handleTransactionCreated(data);
        break;
      case 'balance_changed':
        _handleBalanceChanged(data);
        break;
      case 'pong':
        log('🏓 Pong reçu - connexion active');
        break;
      case 'ping':
        _sendMessage({'type': 'pong'});
        break;
      case 'error':
        log('❌ Erreur WebSocket du serveur: ${data['message']}');
        _messageController?.add({
          'type': 'server_error',
          'message': data['message'],
          'data': data,
        });
        break;
      default:
        if (!_isConnected || !_isAuthenticated) {
          log('🔧 Données métier reçues, auto-correction connexion/auth');
          _handleConnectionEstablished();
          _handleAuthenticated();
        }
        _messageController?.add(data);
    }
  }

  // Déduplication des messages wallet_update
  DateTime? _lastWalletUpdateTime;
  String? _lastWalletUpdateBalance;

  void _handleWalletUpdate(Map<String, dynamic> data) {
    final walletData = data['wallet'] ?? data['data'] ?? data;
    final balance = walletData['balance']?.toString();
    final now = DateTime.now();

    if (_lastWalletUpdateBalance == balance &&
        _lastWalletUpdateTime != null &&
        now.difference(_lastWalletUpdateTime!) < Duration(seconds: 2)) {
      log('⚠️ Wallet update dupliqué ignoré (balance: $balance)');
      return;
    }

    _lastWalletUpdateBalance = balance;
    _lastWalletUpdateTime = now;

    log('💰 Solde mis à jour via WebSocket: ${balance} FCFA');
    _messageController?.add({'type': 'wallet_update', 'data': walletData});
  }

  // Déduplication des messages transaction_created
  Set<String> _processedTransactionIds = <String>{};

  void _handleTransactionCreated(Map<String, dynamic> data) {
    final transactionData = data['transaction'] ?? data['data'] ?? data;
    final transactionId = transactionData['uuid']?.toString();

    if (transactionId != null &&
        _processedTransactionIds.contains(transactionId)) {
      log('⚠️ Transaction dupliquée ignorée (ID: $transactionId)');
      return;
    }

    if (transactionId != null) {
      _processedTransactionIds.add(transactionId);
      if (_processedTransactionIds.length > 100) {
        final oldIds = _processedTransactionIds.take(
          _processedTransactionIds.length - 100,
        );
        _processedTransactionIds.removeAll(oldIds);
      }
    }

    final transactionType =
        transactionData['transaction_type']?.toString() ?? 'inconnue';
    final operator = transactionData['operator']?.toString() ?? '';
    log(
      '💸 Nouvelle transaction: ${transactionType.capitalize()} via $operator',
    );

    _messageController?.add({
      'type': 'transaction_created',
      'data': transactionData,
    });
  }

  void _handleBalanceChanged(Map<String, dynamic> data) {
    _messageController?.add({'type': 'balance_changed', 'data': data});
  }

  void _onError(error) {
    log('❌ Erreur WebSocket: $error');
    _isConnected = false;
    _isAuthenticated = false;
    _isConnecting = false;
    _connectionTimeoutTimer?.cancel();

    _messageController?.add({
      'type': 'connection_error',
      'message': error.toString(),
    });

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  void _onDisconnected() {
    log('🔌 WebSocket déconnecté');
    final wasConnected = _isConnected;

    _isConnected = false;
    _isAuthenticated = false;
    _isConnecting = false;
    _connectionTimeoutTimer?.cancel();
    _stopPing();

    // Nettoyer les caches de déduplication
    _lastWalletUpdateTime = null;
    _lastWalletUpdateBalance = null;
    _processedTransactionIds.clear();

    _messageController?.add({
      'type': 'disconnected',
      'message': 'WebSocket déconnecté',
    });

    if (wasConnected && _shouldReconnect) {
      log('🔄 Programmation de la reconnexion automatique...');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) {
      log('🛑 Reconnexion désactivée');
      return;
    }

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      log('❌ Nombre maximum de tentatives de reconnexion atteint');
      _messageController?.add({
        'type': 'max_reconnect_reached',
        'message': 'Impossible de se reconnecter au serveur',
      });
      return;
    }

    _reconnectAttempts++;
    log(
      '🔄 Tentative de reconnexion ${_reconnectAttempts}/$_maxReconnectAttempts dans ${_reconnectDelay.inSeconds}s',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () async {
      if (_lastToken != null && _shouldReconnect) {
        log('🔄 Exécution de la reconnexion automatique...');
        await connect(_lastToken!);
      }
    });
  }

  void _startPing() {
    _stopPing();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected && _isAuthenticated) {
        _sendMessage({'type': 'ping'});
        log('🏓 Ping envoyé');
      } else {
        log('⚠️ Arrêt du ping - connexion non active');
        _stopPing();
      }
    });
    log('🏓 Ping automatique démarré (${_pingInterval.inSeconds}s)');
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_channel != null && _isConnected) {
      try {
        final jsonMessage = jsonEncode(message);
        _channel!.sink.add(jsonMessage);

        if (message['type'] != 'ping' && message['type'] != 'pong') {
          log('📤 Message WebSocket envoyé: $message');
        }
      } catch (e) {
        log('❌ Erreur envoi message WebSocket: $e');
      }
    } else {
      log('⚠️ WebSocket non connecté, message ignoré: ${message['type']}');
    }
  }

  // Méthodes publiques
  void requestWalletUpdate() {
    if (isConnected) {
      _sendMessage({
        'type': 'get_wallet_data',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      log('⚠️ WebSocket non connecté pour requestWalletUpdate');
    }
  }

  void requestTransactionsHistory({int? limit, int? offset}) {
    if (isConnected) {
      _sendMessage({
        'type': 'get_transactions',
        'limit': limit ?? 20,
        'offset': offset ?? 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<void> reconnect([String? accessToken]) async {
    log('🔄 Reconnexion manuelle demandée');

    final token = accessToken ?? _lastToken;
    if (token == null) {
      log('❌ Aucun token disponible pour la reconnexion');
      return;
    }

    _reconnectAttempts = 0;
    await _cleanupConnection();
    await Future.delayed(Duration(milliseconds: 500));
    await connect(token);
  }

  Future<void> _cleanupConnection() async {
    _reconnectTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
    _stopPing();

    if (_channel != null) {
      try {
        await _channel!.sink.close(ws_status.normalClosure);
        log('🧹 WebSocket fermé proprement');
      } catch (e) {
        log('⚠️ Erreur fermeture propre WebSocket: $e');
      }
      _channel = null;
    }

    _isConnected = false;
    _isAuthenticated = false;
    _isConnecting = false;

    log('🧹 Connexion WebSocket nettoyée complètement');
  }

  void stopAutoReconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    log('🛑 Reconnexions automatiques désactivées');
  }

  void resumeAutoReconnect() {
    _shouldReconnect = true;
    log('▶️ Reconnexions automatiques réactivées');
  }

  Future<void> disconnect() async {
    log('🔌 Déconnexion WebSocket...');
    _shouldReconnect = false;
    await _cleanupConnection();
    log('✅ WebSocket déconnecté');
  }

  bool isReallyConnected() {
    return _isConnected &&
        _isAuthenticated &&
        _channel != null &&
        !_isConnecting &&
        _messageController != null;
  }

  // ⭐ FIX: Méthode pour attendre la connexion avec timeout plus réaliste
  Future<bool> waitForConnection({int timeoutSeconds = 8}) async {
    final startTime = DateTime.now();

    while (!isReallyConnected() &&
        DateTime.now().difference(startTime).inSeconds < timeoutSeconds) {
      await Future.delayed(Duration(milliseconds: 200));
    }

    return isReallyConnected();
  }

  // ⭐ FIX: Méthode de reconnexion avec retry et vérification réseau
  Future<bool> reconnectWithRetry(
    String accessToken, {
    int maxRetries = 3,
  }) async {
    log('🔄 Début reconnectWithRetry avec $maxRetries tentatives');

    // Reset complet avant de commencer
    await _cleanupConnection();
    resetState();

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        log('🔄 Tentative de reconnexion $attempt/$maxRetries');

        // ⭐ FIX: Vérifier la connectivité réseau avant chaque tentative
        if (!await _checkNetworkConnectivity()) {
          log('❌ Pas de connectivité réseau - abandon tentative $attempt');
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: 5));
            continue;
          } else {
            return false;
          }
        }

        // ⭐ FIX: Utiliser un timeout plus court pour les reconnexions
        await Future.any([
          connect(accessToken),
          Future.delayed(Duration(seconds: 8)).then(
            (_) =>
                throw TimeoutException('Connect timeout', Duration(seconds: 8)),
          ),
        ]);

        // ⭐ FIX: Attendre la connexion avec timeout adapté
        final connected = await waitForConnection(timeoutSeconds: 6);

        if (connected && isHealthy()) {
          log('✅ Reconnexion réussie à la tentative $attempt');
          return true;
        } else {
          log('⚠️ Échec reconnexion tentative $attempt - connexion non stable');
          await _cleanupConnection();
          resetState();
        }
      } on TimeoutException catch (e) {
        log('⏰ Timeout reconnexion tentative $attempt: $e');
        await _cleanupConnection();
        resetState();
      } on SocketException catch (e) {
        log('🌐 Erreur réseau reconnexion tentative $attempt: $e');
        await _cleanupConnection();
        resetState();

        // Pour les erreurs réseau, attendre plus longtemps
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 10));
        }
      } catch (e) {
        log('❌ Erreur reconnexion tentative $attempt: $e');
        await _cleanupConnection();
        resetState();
      }

      // Pause progressive avant la prochaine tentative
      if (attempt < maxRetries) {
        final delay = Duration(seconds: attempt * 3); // 3s, 6s, 9s...
        log('⏳ Attente ${delay.inSeconds}s avant prochaine tentative...');
        await Future.delayed(delay);
      }
    }

    log('❌ Échec de toutes les tentatives de reconnexion');
    return false;
  }

  void safeRequestWalletUpdate() {
    if (isReallyConnected()) {
      requestWalletUpdate();
    } else {
      log('⚠️ WebSocket non connecté - requête wallet update ignorée');
    }
  }

  bool isHealthy() {
    final healthy =
        _isConnected &&
        _isAuthenticated &&
        _channel != null &&
        !_isConnecting &&
        _messageController != null;

    if (!healthy) {
      log('🔍 WebSocket Health Check:');
      log('  - Connected: $_isConnected');
      log('  - Authenticated: $_isAuthenticated');
      log('  - Channel: ${_channel != null}');
      log('  - Connecting: $_isConnecting');
      log('  - MessageController: ${_messageController != null}');
    }

    return healthy;
  }

  void resetState() {
    log('🔄 Reset état WebSocket');
    _isConnected = false;
    _isAuthenticated = false;
    _isConnecting = false;
    _reconnectAttempts = 0;

    // Nettoyer les caches
    _lastWalletUpdateTime = null;
    _lastWalletUpdateBalance = null;
    _processedTransactionIds.clear();
  }

  void dispose() {
    _shouldReconnect = false;
    disconnect();
    _messageController?.close();
    _messageController = null;
  }

  void debugFullState() {
    log('=== WEBSOCKET DEBUG STATE ===');
    log('Connected: $_isConnected');
    log('Authenticated: $_isAuthenticated');
    log('Connecting: $_isConnecting');
    log('Should Reconnect: $_shouldReconnect');
    log('Reconnect Attempts: $_reconnectAttempts');
    log('Channel: ${_channel != null}');
    log('Message Controller: ${_messageController != null}');
    log('Last Token: ${_lastToken != null ? "Present" : "Null"}');
    log('============================');
  }

  // ⭐ FIX: Nouvelle méthode pour gérer les erreurs réseau avec délai adaptatif
  void _handleNetworkError() {
    _isConnecting = false;
    _isConnected = false;
    _isAuthenticated = false;

    _messageController?.add({
      'type': 'network_error',
      'message': 'Erreur de réseau - vérifiez votre connexion',
    });

    log('🌐 Erreur réseau - programmation tentative différée...');

    // ⭐ FIX: Délai adaptatif basé sur le nombre de tentatives
    final baseDelay = 15; // 15 secondes de base
    final adaptiveDelay =
        baseDelay + (_reconnectAttempts * 10); // +10s par tentative
    final maxDelay = 60; // Maximum 60 secondes
    final finalDelay = adaptiveDelay > maxDelay ? maxDelay : adaptiveDelay;

    Timer(Duration(seconds: finalDelay), () async {
      if (_lastToken != null && !_isConnected && _shouldReconnect) {
        log(
          '🔄 Nouvelle tentative après erreur réseau (délai: ${finalDelay}s)...',
        );

        // Vérifier la connectivité avant de tenter
        if (await _checkNetworkConnectivity()) {
          await connect(_lastToken!);
        } else {
          log('❌ Toujours pas de connectivité - nouvelle tentative programmée');
          _handleNetworkError(); // Recursif avec délai adaptatif
        }
      }
    });
  }
}

// Extension helper
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
