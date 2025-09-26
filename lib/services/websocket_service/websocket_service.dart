import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class WebSocketService {
  static const String _baseWsUrl = 'ws://10.97.236.253:8000/ws';

  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Timer? _connectionTimeoutTimer;
  Timer? _tabSwitchTimer;

  bool _isConnected = false;
  bool _isAuthenticated = false;
  bool _shouldReconnect = true;
  bool _isConnecting = false;
  bool _appInBackground = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _connectionTimeout = Duration(seconds: 10);

  String? _lastToken;
  String? _connectionId;
  DateTime? _lastMessageTime;

  // Cache des dernières données pour éviter les doublons
  Map<String, dynamic>? _lastWalletData;
  Set<String> _processedMessageIds = <String>{};

  // Getters
  bool get isConnected => _isConnected && _isAuthenticated;
  Stream<Map<String, dynamic>> get messageStream =>
      _messageController?.stream ?? Stream.empty();

  WebSocketService() {
    _messageController = StreamController<Map<String, dynamic>>.broadcast();
    _setupVisibilityHandlers();
  }

  void _setupVisibilityHandlers() {
    // Gérer les changements de visibilité de l'app
    // Cette méthode sera appelée depuis le LifecycleHandler
  }

  void onAppResumed() {
    log('📱 App resumed - checking WebSocket health');
    _appInBackground = false;

    if (!isHealthy() && _lastToken != null) {
      log('🔄 App resumed - reconnecting WebSocket');
      _forceReconnectAfterResume();
    } else if (isHealthy()) {
      // Envoyer une demande de mise à jour pour être sûr
      requestWalletUpdate();
    }
  }

  void onAppPaused() {
    log('📱 App paused');
    _appInBackground = true;
    // Ne pas déconnecter immédiatement, laisser un délai
    _scheduleBackgroundDisconnect();
  }

  void _scheduleBackgroundDisconnect() {
    _tabSwitchTimer?.cancel();
    _tabSwitchTimer = Timer(Duration(seconds: 30), () {
      if (_appInBackground) {
        log('📱 App en arrière-plan depuis 30s - déconnexion WebSocket');
        disconnect();
      }
    });
  }

  Future<void> _forceReconnectAfterResume() async {
    try {
      await _cleanupConnection();
      resetState();

      if (_lastToken != null) {
        await Future.delayed(Duration(milliseconds: 1000));
        await connect(_lastToken!);

        // Attendre que la connexion soit stable puis demander les données
        if (await waitForConnection(timeoutSeconds: 8)) {
          await Future.delayed(Duration(milliseconds: 1500));
          requestWalletUpdate();
          log('✅ Reconnexion après resume réussie');
        }
      }
    } catch (e) {
      log('❌ Erreur reconnexion après resume: $e');
    }
  }

  Future<void> connect(String accessToken) async {
    log(
      '🎯 DEBUT connect() - isConnecting: $_isConnecting, isConnected: $_isConnected',
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

      if (!await _checkNetworkConnectivity()) {
        throw SocketException('No network connectivity');
      }

      final wsUrl = '$_baseWsUrl/wallet/?token=$accessToken';
      log('🌐 Création WebSocketChannel vers: $wsUrl');

      try {
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        log('✅ WebSocketChannel créé');
      } catch (e) {
        log('❌ Erreur création WebSocketChannel: $e');
        _isConnecting = false;
        throw e;
      }

      _startConnectionTimeout(timeoutDuration: _connectionTimeout);

      log('👂 Configuration des listeners...');
      _channel!.stream
          .timeout(
            Duration(seconds: 15),
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

      await Future.delayed(Duration(milliseconds: 500));

      if (!_isConnected && !_isAuthenticated) {
        log('⚠️ Aucune réponse du serveur après 500ms');
      }
    } catch (e) {
      log('❌ Erreur connexion WebSocket: $e');
      _isConnecting = false;
      _connectionTimeoutTimer?.cancel();

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

  Future<bool> _checkNetworkConnectivity() async {
    try {
      final socket = await Socket.connect(
        '10.97.236.253',
        8000,
        timeout: Duration(seconds: 3),
      );
      await socket.close();
      log('✅ Connectivité serveur local OK');
      return true;
    } catch (e) {
      log('❌ Pas de connectivité serveur local: $e');
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(Duration(seconds: 3));
        if (result.isNotEmpty) {
          log('✅ Internet OK mais serveur local inaccessible');
          return false;
        }
      } catch (_) {
        log('❌ Pas d\'internet du tout');
      }
      return false;
    }
  }

  void _startConnectionTimeout({
    Duration timeoutDuration = const Duration(seconds: 10),
  }) {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = Timer(timeoutDuration, () {
      log(
        '⏰ TIMEOUT! isAuthenticated: $_isAuthenticated, isConnected: $_isConnected',
      );

      if (!_isAuthenticated && !_isConnected) {
        log('❌ Timeout de connexion WebSocket - aucune connexion établie');
        _onError('Connection timeout - no connection established');
      } else if (_isConnected && !_isAuthenticated) {
        log('🔧 Connexion établie mais pas marquée comme authentifiée');
        _handleAuthenticated();
      } else {
        log('✅ Timeout ignoré - connexion déjà opérationnelle');
      }
    });
  }

  void _onMessage(dynamic message) {
    try {
      _lastMessageTime = DateTime.now();
      log('📨 Message WebSocket reçu: $message');

      if (message is String) {
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
            try {
              final data = jsonDecode(message);
              log('✅ JSON parsé avec succès: $data');
              _handleJsonMessage(data);
            } catch (e) {
              log('⚠️ Message WebSocket non-JSON: "$message"');
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
    log('🔐 DEBUT _handleAuthenticated() - isAuthenticated: $_isAuthenticated');

    if (!_isAuthenticated) {
      _isAuthenticated = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _connectionTimeoutTimer?.cancel();

      log('✅ Authentification marquée comme réussie');

      _startPing();

      _messageController?.add({
        'type': 'connected',
        'message': 'WebSocket connecté et authentifié avec succès',
      });

      log('🎉 WebSocket complètement opérationnel!');
    }
  }

  void _handleJsonMessage(Map<String, dynamic> data) {
    final type = data['type']?.toString().toLowerCase();
    final messageId =
        data['connection_id']?.toString() ??
        data['timestamp']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    // Vérifier les doublons avec un cache intelligent
    if (_isMessageDuplicate(type, data, messageId)) {
      log('⚠️ Message dupliqué ignoré: $type');
      return;
    }

    if (type == 'connection_established' || type == 'connected') {
      _connectionId = data['connection_id']?.toString();
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
      case 'wallet_data':
        _handleWalletUpdate(data);
        break;
      case 'transaction_created':
      case 'new_transaction':
        _handleTransactionCreated(data);
        break;
      case 'balance_changed':
        _handleBalanceChanged(data);
        break;
      case 'force_refresh':
        _handleForceRefresh(data);
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

  bool _isMessageDuplicate(
    String? type,
    Map<String, dynamic> data,
    String messageId,
  ) {
    if (type == null) return false;

    // Pour les wallet_update, vérifier si les données ont vraiment changé
    if (type == 'wallet_update' || type == 'wallet_data') {
      final walletData = data['wallet'] ?? data['data'] ?? data;
      final balance = walletData['balance']?.toString();
      final timestamp =
          walletData['updated_at']?.toString() ??
          walletData['last_updated']?.toString();

      final currentKey = '$balance-$timestamp';
      final lastKey =
          _lastWalletData != null
              ? '${_lastWalletData!['balance']}-${_lastWalletData!['updated_at'] ?? _lastWalletData!['last_updated']}'
              : '';

      if (currentKey == lastKey && !data.containsKey('force_update')) {
        return true; // Message dupliqué
      }

      _lastWalletData = Map.from(walletData);
      return false;
    }

    // Pour les transactions, utiliser l'UUID
    if (type == 'transaction_created' || type == 'new_transaction') {
      final transactionData = data['transaction'] ?? data['data'] ?? data;
      final transactionId =
          transactionData['uuid']?.toString() ??
          transactionData['id']?.toString();

      if (transactionId != null &&
          _processedMessageIds.contains(transactionId)) {
        return true;
      }

      if (transactionId != null) {
        _processedMessageIds.add(transactionId);
        // Nettoyer le cache si trop grand
        if (_processedMessageIds.length > 100) {
          final toRemove = _processedMessageIds.take(
            _processedMessageIds.length - 100,
          );
          _processedMessageIds.removeAll(toRemove);
        }
      }
      return false;
    }

    // Pour les autres messages, utiliser un cache temporaire simple
    final cacheKey = '$type-$messageId';
    if (_processedMessageIds.contains(cacheKey)) {
      return true;
    }

    _processedMessageIds.add(cacheKey);
    return false;
  }

  void _handleWalletUpdate(Map<String, dynamic> data) {
    final walletData = data['wallet'] ?? data['data'] ?? data;
    final balance = walletData['balance']?.toString();

    log('💰 Solde mis à jour via WebSocket: $balance FCFA');

    _messageController?.add({
      'type': 'wallet_update',
      'data': walletData,
      'force_update': data['force_update'] ?? false,
    });
  }

  void _handleTransactionCreated(Map<String, dynamic> data) {
    final transactionData = data['transaction'] ?? data['data'] ?? data;
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

    // Après une transaction, demander une mise à jour du wallet
    Future.delayed(Duration(milliseconds: 500), () {
      requestWalletUpdate();
    });
  }

  void _handleBalanceChanged(Map<String, dynamic> data) {
    _messageController?.add({'type': 'balance_changed', 'data': data});
  }

  void _handleForceRefresh(Map<String, dynamic> data) {
    log('🔄 Force refresh reçu du serveur');

    // Nettoyer les caches
    _lastWalletData = null;
    _processedMessageIds.clear();

    _messageController?.add({'type': 'force_refresh', 'data': data});

    // Demander immédiatement les nouvelles données
    requestWalletUpdate();
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

    if (_shouldReconnect && !_appInBackground) {
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
    _lastWalletData = null;
    _processedMessageIds.clear();

    _messageController?.add({
      'type': 'disconnected',
      'message': 'WebSocket déconnecté',
    });

    if (wasConnected && _shouldReconnect && !_appInBackground) {
      log('🔄 Programmation de la reconnexion automatique...');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect || _appInBackground) {
      log('🛑 Reconnexion désactivée ou app en background');
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
    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );

    log(
      '🔄 Tentative de reconnexion $_reconnectAttempts/$_maxReconnectAttempts dans ${delay.inSeconds}s',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      if (_lastToken != null && _shouldReconnect && !_appInBackground) {
        log('🔄 Exécution de la reconnexion automatique...');
        await connect(_lastToken!);
      }
    });
  }

  void _startPing() {
    _stopPing();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected && _isAuthenticated && !_appInBackground) {
        _sendMessage({'type': 'ping'});
        log('🏓 Ping envoyé');

        // Vérifier si on a reçu des messages récemment
        if (_lastMessageTime != null) {
          final timeSinceLastMessage = DateTime.now().difference(
            _lastMessageTime!,
          );
          if (timeSinceLastMessage.inMinutes > 2) {
            log(
              '⚠️ Aucun message depuis 2 minutes - possible connexion fantôme',
            );
            _scheduleReconnect();
          }
        }
      } else {
        log('⚠️ Arrêt du ping - connexion non active ou app en background');
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

  // Méthodes publiques améliorées
  void requestWalletUpdate({bool forceRefresh = false}) {
    if (isConnected) {
      _sendMessage({
        'type': 'get_wallet_data',
        'force_refresh': forceRefresh,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      log('📤 Demande wallet update envoyée (force: $forceRefresh)');
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

  void forceRefresh() {
    if (isConnected) {
      _sendMessage({
        'type': 'force_refresh',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      log('🔄 Force refresh demandé');
    } else {
      log('⚠️ WebSocket non connecté pour forceRefresh');
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

  Future<bool> reconnectWithRetry(
    String accessToken, {
    int maxRetries = 3,
  }) async {
    log('🔄 Début reconnectWithRetry avec $maxRetries tentatives');

    await _cleanupConnection();
    resetState();

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        log('🔄 Tentative de reconnexion $attempt/$maxRetries');

        if (!await _checkNetworkConnectivity()) {
          log('❌ Pas de connectivité réseau - abandon tentative $attempt');
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: 5));
            continue;
          } else {
            return false;
          }
        }

        await Future.any([
          connect(accessToken),
          Future.delayed(Duration(seconds: 10)).then(
            (_) =>
                throw TimeoutException(
                  'Connect timeout',
                  Duration(seconds: 10),
                ),
          ),
        ]);

        final connected = await waitForConnection(timeoutSeconds: 8);

        if (connected && isHealthy()) {
          log('✅ Reconnexion réussie à la tentative $attempt');
          return true;
        } else {
          log('⚠️ Échec reconnexion tentative $attempt - connexion non stable');
          await _cleanupConnection();
          resetState();
        }
      } catch (e) {
        log('❌ Erreur reconnexion tentative $attempt: $e');
        await _cleanupConnection();
        resetState();
      }

      if (attempt < maxRetries) {
        final delay = Duration(seconds: attempt * 3);
        log('⏳ Attente ${delay.inSeconds}s avant prochaine tentative...');
        await Future.delayed(delay);
      }
    }

    log('❌ Échec de toutes les tentatives de reconnexion');
    return false;
  }

  Future<void> _cleanupConnection() async {
    _reconnectTimer?.cancel();
    _connectionTimeoutTimer?.cancel();
    _tabSwitchTimer?.cancel();
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
    _connectionId = null;

    log('🧹 Connexion WebSocket nettoyée complètement');
  }

  void resetState() {
    log('🔄 Reset état WebSocket');
    _isConnected = false;
    _isAuthenticated = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
    _connectionId = null;
    _lastMessageTime = null;

    // Nettoyer les caches
    _lastWalletData = null;
    _processedMessageIds.clear();
  }

  bool isReallyConnected() {
    return _isConnected &&
        _isAuthenticated &&
        _channel != null &&
        !_isConnecting &&
        _messageController != null;
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
      log('  - Connection ID: $_connectionId');
    }

    return healthy;
  }

  Future<bool> waitForConnection({int timeoutSeconds = 10}) async {
    final startTime = DateTime.now();

    while (!isHealthy() &&
        DateTime.now().difference(startTime).inSeconds < timeoutSeconds) {
      await Future.delayed(Duration(milliseconds: 200));
    }

    return isHealthy();
  }

  void _handleNetworkError() {
    _isConnecting = false;
    _isConnected = false;
    _isAuthenticated = false;

    _messageController?.add({
      'type': 'network_error',
      'message': 'Erreur de réseau - vérifiez votre connexion',
    });

    log('🌐 Erreur réseau - programmation tentative différée...');

    final baseDelay = 15;
    final adaptiveDelay = baseDelay + (_reconnectAttempts * 10);
    final maxDelay = 60;
    final finalDelay = adaptiveDelay > maxDelay ? maxDelay : adaptiveDelay;

    Timer(Duration(seconds: finalDelay), () async {
      if (_lastToken != null &&
          !_isConnected &&
          _shouldReconnect &&
          !_appInBackground) {
        log(
          '🔄 Nouvelle tentative après erreur réseau (délai: ${finalDelay}s)...',
        );

        if (await _checkNetworkConnectivity()) {
          await connect(_lastToken!);
        } else {
          log('❌ Toujours pas de connectivité - nouvelle tentative programmée');
          _handleNetworkError();
        }
      }
    });
  }

  // Méthodes publiques de contrôle
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
    resetState();
    log('✅ WebSocket déconnecté');
  }

  void dispose() {
    _shouldReconnect = false;
    disconnect();
    _messageController?.close();
    _messageController = null;
  }

  // Méthodes de debug
  void debugFullState() {
    log('=== WEBSOCKET DEBUG STATE ===');
    log('Connected: $_isConnected');
    log('Authenticated: $_isAuthenticated');
    log('Connecting: $_isConnecting');
    log('Should Reconnect: $_shouldReconnect');
    log('App In Background: $_appInBackground');
    log('Reconnect Attempts: $_reconnectAttempts');
    log('Channel: ${_channel != null}');
    log('Message Controller: ${_messageController != null}');
    log('Connection ID: $_connectionId');
    log('Last Token: ${_lastToken != null ? "Present" : "Null"}');
    log('Last Message Time: $_lastMessageTime');
    log('============================');
  }
}

// Extension helper
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
