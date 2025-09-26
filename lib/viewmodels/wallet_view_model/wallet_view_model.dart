// lib/viewmodels/wallet_view_model/wallet_view_model.dart
// import 'dart:async';
// import 'dart:developer';
// import 'package:akiba/services/wallet_service/wallet_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:akiba/models/wallet_models/wallet_model.dart';
// import 'package:akiba/models/wallet_models/transaction_model.dart';
// import 'package:akiba/services/auth_service/auth_service.dart';
// import 'package:akiba/services/websocket_service/websocket_service.dart';
// import 'wallet_state.dart';

// class WalletNotifier extends StateNotifier<WalletState> {
//   final WalletService _walletService = WalletService();
//   final AuthService _authService = AuthService();
//   final WebSocketService _webSocketService = WebSocketService();

//   StreamSubscription? _webSocketSubscription;
//   Timer? _reconnectTimer;

//   WalletNotifier() : super(WalletState()) {
//     _initializeWebSocket();
//   }

//   Future<void> _initializeWebSocket() async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken != null && !_authService.isTokenExpired(accessToken)) {
//         await _connectWebSocket(accessToken);
//         _listenToWebSocketMessages();
//       }
//     } catch (e) {
//       log('❌ Erreur initialisation WebSocket: $e');
//     }
//   }

//   Future<void> _connectWebSocket(String token) async {
//     try {
//       await _webSocketService.connect(token);
//       state = state.copyWith(isConnected: _webSocketService.isConnected);
//       log('✅ WebSocket connecté pour le wallet');
//     } catch (e) {
//       log('❌ Erreur connexion WebSocket wallet: $e');
//       state = state.copyWith(isConnected: false);
//     }
//   }

//   void _listenToWebSocketMessages() {
//     _webSocketSubscription?.cancel();
//     _webSocketSubscription = _webSocketService.messageStream.listen(
//       (message) {
//         _handleWebSocketMessage(message);
//       },
//       onError: (error) {
//         log('❌ Erreur stream WebSocket: $error');
//         state = state.copyWith(isConnected: false);
//         _scheduleReconnect();
//       },
//     );
//   }

//   void _handleWebSocketMessage(Map<String, dynamic> message) {
//     try {
//       switch (message['type']) {
//         case 'wallet_update':
//           _handleWalletUpdate(message['data']);
//           break;

//         case 'transaction_created':
//           _handleNewTransaction(message['data']);
//           break;

//         case 'balance_changed':
//           _handleBalanceChange(message['data']);
//           break;

//         // ⭐ NOUVEAU : Gérer les demandes de PIN
//         case 'pin_required':
//           _handlePinRequired(message['data']);
//           break;

//         default:
//           log('Message WebSocket non géré: ${message['type']}');
//       }
//     } catch (e) {
//       log('❌ Erreur traitement message WebSocket: $e');
//     }
//   }

//   void _handleWalletUpdate(Map<String, dynamic> data) {
//     try {
//       final updatedWallet = WalletModel.fromJson(data);
//       state = state.copyWith(wallet: updatedWallet);
//       log(
//         '💰 Solde mis à jour via WebSocket: ${updatedWallet.formattedBalance}',
//       );
//     } catch (e) {
//       log('❌ Erreur mise à jour wallet: $e');
//     }
//   }

//   void _handleNewTransaction(Map<String, dynamic> data) {
//     try {
//       final newTransaction = TransactionModel.fromJson(data);
//       final updatedTransactions = [newTransaction, ...state.transactions];
//       state = state.copyWith(transactions: updatedTransactions);
//       log(
//         '💸 Nouvelle transaction via WebSocket: ${newTransaction.displayTitle}',
//       );
//     } catch (e) {
//       log('❌ Erreur nouvelle transaction: $e');
//     }
//   }

//   void _handleBalanceChange(Map<String, dynamic> data) {
//     if (state.wallet != null) {
//       final newBalance = (data['balance'] ?? 0.0).toDouble();
//       final updatedWallet = state.wallet!.copyWith(
//         balance: newBalance,
//         updatedAt: DateTime.now(),
//       );
//       state = state.copyWith(wallet: updatedWallet);
//       log(
//         '💰 Balance changée via WebSocket: ${updatedWallet.formattedBalance}',
//       );
//     }
//   }

//   // ⭐ NOUVEAU : Gérer les demandes de PIN
//   void _handlePinRequired(Map<String, dynamic> data) {
//     log('🔐 PIN requis pour accéder au wallet');
//     state = state.copyWith(
//       error: 'Authentification PIN requise pour accéder au portefeuille',
//       requiresPinAuth: true,
//     );
//   }

//   void _scheduleReconnect() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(const Duration(seconds: 5), () async {
//       try {
//         final accessToken = await _authService.getAccessToken();
//         if (accessToken != null && !_authService.isTokenExpired(accessToken)) {
//           await _connectWebSocket(accessToken);
//           _listenToWebSocketMessages();
//         }
//       } catch (e) {
//         log('❌ Erreur reconnexion WebSocket: $e');
//       }
//     });
//   }

//   // ⭐ MODIFIÉ : Charger les données du wallet avec gestion PIN
//   Future<void> loadWalletData() async {
//     if (state.isLoading) return;

//     state = state.copyWith(isLoading: true, clearError: true);

//     try {
//       // ⭐ Vérifier d'abord le statut d'authentification
//       await _checkAuthenticationStatus();

//       final response = await _walletService.getWalletData();

//       if (response != null && response.success) {
//         state = state.copyWith(
//           wallet: response.wallet,
//           transactions: response.transactions ?? [],
//           isLoading: false,
//           requiresPinAuth: false, // PIN OK
//         );
//         log('✅ Données wallet chargées: ${response.wallet?.formattedBalance}');
//       } else {
//         state = state.copyWith(
//           isLoading: false,
//           error: 'Impossible de récupérer les données du wallet',
//         );
//       }
//     } catch (e) {
//       log('❌ Erreur chargement wallet: $e');

//       // ⭐ Vérifier si c'est une erreur de PIN
//       if (e.toString().contains('PIN')) {
//         state = state.copyWith(
//           isLoading: false,
//           error: 'Authentification PIN requise',
//           requiresPinAuth: true,
//         );
//       } else {
//         state = state.copyWith(
//           isLoading: false,
//           error: _getUserFriendlyError(e),
//         );
//       }
//     }
//   }

//   // ⭐ NOUVEAU : Vérifier le statut d'authentification
//   Future<void> _checkAuthenticationStatus() async {
//     try {
//       final authStatus = await _authService.checkAuthStatus();

//       if (authStatus.requiredPinAuth) {
//         throw Exception('Authentification PIN requise');
//       }
//     } catch (e) {
//       log('❌ Erreur vérification auth status: $e');
//       rethrow;
//     }
//   }

//   // ⭐ NOUVEAU : Convertir les erreurs en messages utilisateur
//   String _getUserFriendlyError(dynamic error) {
//     final errorString = error.toString().toLowerCase();

//     if (errorString.contains('network') || errorString.contains('connection')) {
//       return 'Erreur réseau. Vérifiez votre connexion.';
//     } else if (errorString.contains('timeout')) {
//       return 'Délai d\'attente dépassé. Réessayez.';
//     } else if (errorString.contains('pin')) {
//       return 'Authentification PIN requise';
//     } else if (errorString.contains('token') ||
//         errorString.contains('unauthorized')) {
//       return 'Session expirée. Reconnectez-vous.';
//     } else {
//       return 'Erreur réseau (Inconnue)';
//     }
//   }

//   // ⭐ MODIFIÉ : Rafraîchir avec gestion d'erreur améliorée
//   Future<void> refreshWallet() async {
//     if (state.isRefreshing) return;

//     state = state.copyWith(isRefreshing: true);

//     try {
//       // ⭐ Méthode alternative : utiliser le token frais
//       final response = await _walletService.getWalletDataWithFreshToken();

//       if (response != null && response.success) {
//         state = state.copyWith(
//           wallet: response.wallet,
//           transactions: response.transactions ?? [],
//           isRefreshing: false,
//           clearError: true,
//           requiresPinAuth: false,
//         );
//         log('✅ Wallet rafraîchi avec succès');
//       } else {
//         // Demander une mise à jour via WebSocket en backup
//         _webSocketService.requestWalletUpdate();
//         state = state.copyWith(isRefreshing: false);
//       }
//     } catch (e) {
//       log('❌ Erreur refresh wallet: $e');

//       if (e.toString().contains('PIN')) {
//         state = state.copyWith(
//           isRefreshing: false,
//           error: 'Authentification PIN requise',
//           requiresPinAuth: true,
//         );
//       } else {
//         state = state.copyWith(
//           isRefreshing: false,
//           error: _getUserFriendlyError(e),
//         );
//       }
//     }
//   }

//   // ⭐ NOUVEAU : Réessayer après authentification PIN
//   Future<void> retryAfterPinAuth() async {
//     state = state.copyWith(requiresPinAuth: false, clearError: true);
//     await loadWalletData();
//   }

//   // Charger l'historique des transactions
//   Future<void> loadTransactionHistory() async {
//     try {
//       _webSocketService.requestTransactionsHistory();
//       final response = await _walletService.getTransactionHistory();

//       if (response != null && response.success) {
//         state = state.copyWith(transactions: response.transactions ?? []);
//         log(
//           '✅ Historique transactions chargé: ${response.transactions?.length ?? 0} transactions',
//         );
//       }
//     } catch (e) {
//       log('❌ Erreur chargement historique: $e');
//       state = state.copyWith(error: _getUserFriendlyError(e));
//     }
//   }

//   // ⭐ NOUVEAU : Effacer l'erreur
//   void clearError() {
//     state = state.copyWith(clearError: true, requiresPinAuth: false);
//   }

//   // Reconnecter WebSocket manuellement
//   Future<void> reconnectWebSocket() async {
//     try {
//       await _webSocketService.disconnect();
//       await _initializeWebSocket();
//     } catch (e) {
//       log('❌ Erreur reconnexion manuelle: $e');
//     }
//   }

//   // Nettoyer les données
//   void clearWallet() {
//     state = WalletState();
//     log('🧹 Données wallet nettoyées');
//   }

//   // Getters utiles
//   bool get hasWallet => state.hasWallet;
//   bool get isWebSocketConnected => state.isConnected;
//   double get currentBalance => state.balance;
//   bool get requiresPinAuth => state.requiresPinAuth;

//   @override
//   void dispose() {
//     _webSocketSubscription?.cancel();
//     _reconnectTimer?.cancel();
//     _webSocketService.dispose();
//     super.dispose();
//   }
// }

// lib/viewmodels/wallet_view_model/wallet_view_model.dart - VERSION AMÉLIORÉE
import 'dart:async';
import 'dart:developer';
import 'package:akiba/services/wallet_service/wallet_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akiba/models/wallet_models/wallet_model.dart';
import 'package:akiba/models/wallet_models/transaction_model.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/services/websocket_service/websocket_service.dart';
import 'wallet_state.dart';

// class WalletNotifier extends StateNotifier<WalletState> {
//   final WalletService _walletService = WalletService();
//   final AuthService _authService = AuthService();
//   final WebSocketService _webSocketService = WebSocketService();

//   StreamSubscription? _webSocketSubscription;
//   Timer? _reconnectTimer;
//   Timer? _healthCheckTimer;

//   WalletNotifier() : super(WalletState()) {
//     _initializeServices();
//   }

//   Future<void> _initializeServices() async {
//     try {
//       log('🚀 Initialisation des services wallet...');

//       // Vérifier d'abord l'authentification
//       final isAuthenticated = await _checkAuthentication();
//       if (!isAuthenticated) {
//         log('⚠️ Utilisateur non authentifié');
//         return;
//       }

//       // Initialiser WebSocket
//       await _initializeWebSocket();

//       // Démarrer le health check
//       _startHealthCheck();

//       log('✅ Services wallet initialisés');
//     } catch (e) {
//       log('❌ Erreur initialisation services: $e');
//       state = state.copyWith(
//         error: 'Erreur d\'initialisation des services',
//         isConnected: false,
//       );
//     }
//   }

//   Future<bool> _checkAuthentication() async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken == null) return false;

//       if (_authService.isTokenExpired(accessToken)) {
//         log('🔄 Token expiré, tentative de refresh...');
//         return await _authService.refreshAuthToken();
//       }

//       return true;
//     } catch (e) {
//       log('❌ Erreur vérification auth: $e');
//       return false;
//     }
//   }

//   Future<void> _initializeWebSocket() async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken != null && !_authService.isTokenExpired(accessToken)) {
//         await _connectWebSocket(accessToken);
//         _listenToWebSocketMessages();
//       } else {
//         log('⚠️ Token invalide pour WebSocket');
//       }
//     } catch (e) {
//       log('❌ Erreur initialisation WebSocket: $e');
//     }
//   }

//   Future<void> _connectWebSocket(String token) async {
//     try {
//       await _webSocketService.connect(token);
//       state = state.copyWith(isConnected: _webSocketService.isConnected);
//       log('✅ WebSocket connecté pour le wallet');
//     } catch (e) {
//       log('❌ Erreur connexion WebSocket wallet: $e');
//       state = state.copyWith(isConnected: false);
//     }
//   }

//   void _listenToWebSocketMessages() {
//     _webSocketSubscription?.cancel();
//     _webSocketSubscription = _webSocketService.messageStream.listen(
//       (message) {
//         _handleWebSocketMessage(message);
//       },
//       onError: (error) {
//         log('❌ Erreur stream WebSocket: $error');
//         state = state.copyWith(isConnected: false);
//         _scheduleReconnect();
//       },
//     );
//   }

//   void _handleWebSocketMessage(Map<String, dynamic> message) {
//     try {
//       log('📨 Message WebSocket reçu: ${message['type']}');

//       switch (message['type']) {
//         case 'connected':
//           state = state.copyWith(isConnected: true, clearError: true);
//           log('✅ WebSocket connecté et authentifié');
//           break;

//         case 'wallet_update':
//           _handleWalletUpdate(message['data']);
//           break;

//         case 'transaction_created':
//         case 'new_transaction':
//           _handleNewTransaction(message['data']);
//           break;

//         case 'balance_changed':
//           _handleBalanceChange(message['data']);
//           break;

//         case 'pin_required':
//           _handlePinRequired(message['data']);
//           break;

//         case 'connection_error':
//         case 'server_error':
//           _handleConnectionError(message['message']);
//           break;

//         case 'auth_failed':
//           _handleAuthenticationFailed();
//           break;

//         case 'disconnected':
//           state = state.copyWith(isConnected: false);
//           log('🔌 WebSocket déconnecté');
//           break;

//         case 'reconnect_needed':
//           _scheduleReconnect();
//           break;

//         case 'max_reconnect_reached':
//           state = state.copyWith(
//             isConnected: false,
//             error:
//                 'Impossible de se connecter au serveur. Vérifiez votre connexion.',
//           );
//           break;

//         default:
//           log('Message WebSocket non géré: ${message['type']}');
//       }
//     } catch (e) {
//       log('❌ Erreur traitement message WebSocket: $e');
//     }
//   }

//   void _handleWalletUpdate(Map<String, dynamic>? data) {
//     try {
//       if (data != null) {
//         final updatedWallet = WalletModel.fromJson(data);
//         state = state.copyWith(wallet: updatedWallet, clearError: true);
//         log(
//           '💰 Solde mis à jour via WebSocket: ${updatedWallet.formattedBalance}',
//         );
//       }
//     } catch (e) {
//       log('❌ Erreur mise à jour wallet: $e');
//     }
//   }

//   void _handleNewTransaction(Map<String, dynamic>? data) {
//     try {
//       if (data != null) {
//         final newTransaction = TransactionModel.fromJson(data);
//         final updatedTransactions = [newTransaction, ...state.transactions];

//         state = state.copyWith(
//           transactions: updatedTransactions,
//           clearError: true,
//         );

//         log('💸 Nouvelle transaction: ${newTransaction.displayTitle}');

//         // Optionnel: Demander une mise à jour du wallet pour le solde
//         _webSocketService.requestWalletUpdate();
//       }
//     } catch (e) {
//       log('❌ Erreur nouvelle transaction: $e');
//     }
//   }

//   void _handleBalanceChange(Map<String, dynamic> data) {
//     if (state.wallet != null) {
//       try {
//         final newBalance =
//             (data['balance'] ?? data['new_balance'] ?? 0.0).toDouble();
//         final updatedWallet = state.wallet!.copyWith(
//           balance: newBalance,
//           updatedAt: DateTime.now(),
//         );

//         state = state.copyWith(wallet: updatedWallet);
//         log('💰 Balance changée: ${updatedWallet.formattedBalance}');
//       } catch (e) {
//         log('❌ Erreur changement balance: $e');
//       }
//     }
//   }

//   void _handlePinRequired(Map<String, dynamic>? data) {
//     log('🔐 PIN requis pour accéder au wallet');
//     state = state.copyWith(
//       error: 'Authentification PIN requise pour accéder au portefeuille',
//       requiresPinAuth: true,
//     );
//   }

//   void _handleConnectionError(String? message) {
//     state = state.copyWith(
//       isConnected: false,
//       error: message ?? 'Erreur de connexion WebSocket',
//     );
//   }

//   void _handleAuthenticationFailed() {
//     log('🔐 Authentification WebSocket échouée');
//     state = state.copyWith(
//       isConnected: false,
//       error: 'Authentification échouée. Reconnectez-vous.',
//       requiresPinAuth: true,
//     );
//   }

//   void _scheduleReconnect() {
//     _reconnectTimer?.cancel();
//     _reconnectTimer = Timer(const Duration(seconds: 5), () async {
//       try {
//         log('🔄 Tentative de reconnexion WebSocket...');
//         final isAuthenticated = await _checkAuthentication();

//         if (isAuthenticated) {
//           final accessToken = await _authService.getAccessToken();
//           if (accessToken != null) {
//             await _webSocketService.reconnect(accessToken);
//           }
//         } else {
//           log('⚠️ Réauthentification requise pour WebSocket');
//           state = state.copyWith(requiresPinAuth: true);
//         }
//       } catch (e) {
//         log('❌ Erreur reconnexion WebSocket: $e');
//       }
//     });
//   }

//   // ⭐ NOUVEAU : Health check périodique
//   void _startHealthCheck() {
//     _healthCheckTimer?.cancel();
//     _healthCheckTimer = Timer.periodic(Duration(minutes: 2), (timer) {
//       if (!_webSocketService.isHealthy()) {
//         log('⚠️ WebSocket en mauvaise santé, reconnexion...');
//         _scheduleReconnect();
//       }
//     });
//   }

//   // ⭐ MODIFIÉ : Charger les données avec meilleure gestion d'erreur
//   Future<void> loadWalletData({bool forceRefresh = false}) async {
//     if (state.isLoading && !forceRefresh) return;

//     state = state.copyWith(isLoading: true, clearError: true);

//     try {
//       // Vérifier l'authentification
//       final isAuthenticated = await _checkAuthentication();
//       if (!isAuthenticated) {
//         throw Exception('Session expirée. Reconnectez-vous.');
//       }

//       // Charger les données
//       final response = await _walletService.getWalletData();

//       if (response != null && response.success) {
//         state = state.copyWith(
//           wallet: response.wallet,
//           transactions: response.transactions ?? [],
//           isLoading: false,
//           requiresPinAuth: false,
//           clearError: true,
//         );

//         log('✅ Données wallet chargées: ${response.wallet?.formattedBalance}');

//         // S'assurer que WebSocket est connecté
//         if (!state.isConnected) {
//           _scheduleReconnect();
//         }
//       } else {
//         throw Exception(
//           response?.message ?? 'Erreur de récupération des données',
//         );
//       }
//     } catch (e) {
//       log('❌ Erreur chargement wallet: $e');

//       final errorMessage = _getUserFriendlyError(e);
//       final requiresPin =
//           e.toString().toLowerCase().contains('pin') ||
//           e.toString().toLowerCase().contains('auth');

//       state = state.copyWith(
//         isLoading: false,
//         error: errorMessage,
//         requiresPinAuth: requiresPin,
//       );
//     }
//   }

//   // ⭐ AMÉLIORÉ : Refresh avec fallback WebSocket
//   Future<void> refreshWallet() async {
//     if (state.isRefreshing) return;

//     state = state.copyWith(isRefreshing: true, clearError: true);

//     try {
//       // Méthode 1: API REST
//       final response = await _walletService.getWalletDataWithFreshToken();

//       if (response != null && response.success) {
//         state = state.copyWith(
//           wallet: response.wallet,
//           transactions: response.transactions ?? [],
//           isRefreshing: false,
//           requiresPinAuth: false,
//         );
//         log('✅ Wallet rafraîchi via API');
//       } else {
//         // Méthode 2: WebSocket fallback
//         log('⚠️ API failed, trying WebSocket...');
//         _webSocketService.requestWalletUpdate();

//         // Attendre un peu pour la réponse WebSocket
//         await Future.delayed(Duration(seconds: 2));
//         state = state.copyWith(isRefreshing: false);
//       }
//     } catch (e) {
//       log('❌ Erreur refresh wallet: $e');

//       // Essayer WebSocket en dernier recours
//       _webSocketService.requestWalletUpdate();

//       final errorMessage = _getUserFriendlyError(e);
//       final requiresPin = e.toString().toLowerCase().contains('pin');

//       state = state.copyWith(
//         isRefreshing: false,
//         error: errorMessage,
//         requiresPinAuth: requiresPin,
//       );
//     }
//   }

//   String _getUserFriendlyError(dynamic error) {
//     final errorString = error.toString().toLowerCase();

//     if (errorString.contains('network') || errorString.contains('connection')) {
//       return 'Erreur réseau. Vérifiez votre connexion.';
//     } else if (errorString.contains('timeout')) {
//       return 'Délai d\'attente dépassé. Réessayez.';
//     } else if (errorString.contains('pin') || errorString.contains('auth')) {
//       return 'Authentification requise';
//     } else if (errorString.contains('token') ||
//         errorString.contains('unauthorized')) {
//       return 'Session expirée. Reconnectez-vous.';
//     } else if (errorString.contains('server')) {
//       return 'Erreur serveur. Réessayez plus tard.';
//     } else {
//       return 'Erreur inconnue. Contactez le support.';
//     }
//   }

//   // ⭐ NOUVEAU : Reconnexion manuelle complète
//   Future<void> forceReconnect() async {
//     try {
//       log('🔄 Reconnexion forcée...');

//       // Déconnecter WebSocket
//       await _webSocketService.disconnect();

//       // Vérifier/rafraîchir l'authentification
//       final refreshed = await _authService.refreshAuthToken();
//       if (!refreshed) {
//         throw Exception('Impossible de rafraîchir l\'authentification');
//       }

//       // Attendre un peu
//       await Future.delayed(Duration(seconds: 1));

//       // Reconnecter WebSocket
//       await _initializeWebSocket();

//       // Recharger les données
//       await loadWalletData(forceRefresh: true);

//       log('✅ Reconnexion forcée réussie');
//     } catch (e) {
//       log('❌ Erreur reconnexion forcée: $e');
//       state = state.copyWith(
//         error: 'Erreur de reconnexion. Redémarrez l\'application.',
//         isConnected: false,
//       );
//     }
//   }

//   // Autres méthodes...
//   Future<void> loadTransactionHistory() async {
//     try {
//       if (state.isConnected) {
//         _webSocketService.requestTransactionsHistory();
//       }

//       final response = await _walletService.getTransactionHistory();

//       if (response != null && response.success) {
//         state = state.copyWith(
//           transactions: response.transactions ?? [],
//           clearError: true,
//         );
//         log(
//           '✅ Historique chargé: ${response.transactions?.length ?? 0} transactions',
//         );
//       }
//     } catch (e) {
//       log('❌ Erreur chargement historique: $e');
//       state = state.copyWith(error: _getUserFriendlyError(e));
//     }
//   }

//   Future<void> retryAfterPinAuth() async {
//     state = state.copyWith(requiresPinAuth: false, clearError: true);
//     await Future.delayed(Duration(milliseconds: 500));
//     await loadWalletData(forceRefresh: true);
//   }

//   void clearError() {
//     state = state.copyWith(clearError: true, requiresPinAuth: false);
//   }

//   void clearWallet() {
//     state = WalletState();
//     log('🧹 Données wallet nettoyées');
//   }

//   // Getters
//   bool get hasWallet => state.hasWallet;
//   bool get isWebSocketConnected => state.isConnected;
//   double get currentBalance => state.balance;
//   bool get requiresPinAuth => state.requiresPinAuth;

//   @override
//   void dispose() {
//     log('🧹 Nettoyage WalletNotifier...');
//     _webSocketSubscription?.cancel();
//     _reconnectTimer?.cancel();
//     _healthCheckTimer?.cancel();
//     _webSocketService.dispose();
//     super.dispose();
//   }
// }

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _walletService = WalletService();
  final AuthService _authService = AuthService();
  final WebSocketService _webSocketService = WebSocketService();

  StreamSubscription? _webSocketSubscription;
  Timer? _reconnectTimer;
  Timer? _healthCheckTimer;
  Timer? _retryTimer;

  // Cache pour éviter les mises à jour redondantes
  Map<String, dynamic>? _lastWalletDataFromWS;
  DateTime? _lastUpdateTime;

  WalletNotifier() : super(WalletState()) {
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      log('🚀 Initialisation des services wallet...');

      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        log('⚠️ Utilisateur non authentifié');
        return;
      }

      await _initializeWebSocket();
      _startHealthCheck();

      log('✅ Services wallet initialisés');
    } catch (e) {
      log('❌ Erreur initialisation services: $e');
      state = state.copyWith(
        error: 'Erreur d\'initialisation des services',
        isConnected: false,
      );
    }
  }

  Future<bool> _checkAuthentication() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) return false;

      if (_authService.isTokenExpired(accessToken)) {
        log('🔄 Token expiré, tentative de refresh...');
        return await _authService.refreshAuthToken();
      }

      return true;
    } catch (e) {
      log('❌ Erreur vérification auth: $e');
      return false;
    }
  }

  Future<void> _initializeWebSocket() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken != null && !_authService.isTokenExpired(accessToken)) {
        await _connectWebSocket(accessToken);
        _listenToWebSocketMessages();
      } else {
        log('⚠️ Token invalide pour WebSocket');
      }
    } catch (e) {
      log('❌ Erreur initialisation WebSocket: $e');
    }
  }

  Future<void> _connectWebSocket(String token) async {
    try {
      await _webSocketService.connect(token);
      state = state.copyWith(isConnected: _webSocketService.isConnected);
      log('✅ WebSocket connecté pour le wallet');
    } catch (e) {
      log('❌ Erreur connexion WebSocket wallet: $e');
      state = state.copyWith(isConnected: false);
    }
  }

  void _listenToWebSocketMessages() {
    _webSocketSubscription?.cancel();
    _webSocketSubscription = _webSocketService.messageStream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        log('❌ Erreur stream WebSocket: $error');
        state = state.copyWith(isConnected: false);
        _scheduleReconnect();
      },
    );
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    try {
      log('📨 Message WebSocket reçu dans wallet: ${message['type']}');

      switch (message['type']) {
        case 'connected':
          state = state.copyWith(isConnected: true, clearError: true);
          log('✅ WebSocket connecté et authentifié');

          // Demander immédiatement une mise à jour des données
          Future.delayed(Duration(milliseconds: 500), () {
            _webSocketService.requestWalletUpdate(forceRefresh: true);
          });
          break;

        case 'wallet_update':
        case 'wallet_data':
          _handleWalletUpdate(message['data'], message['force_update'] == true);
          break;

        case 'transaction_created':
        case 'new_transaction':
          _handleNewTransaction(message['data']);
          break;

        case 'balance_changed':
          _handleBalanceChange(message['data']);
          break;

        case 'force_refresh':
          _handleForceRefresh(message['data']);
          break;

        case 'pin_required':
          _handlePinRequired(message['data']);
          break;

        case 'connection_error':
        case 'server_error':
          _handleConnectionError(message['message']);
          break;

        case 'auth_failed':
          _handleAuthenticationFailed();
          break;

        case 'disconnected':
          state = state.copyWith(isConnected: false);
          log('🔌 WebSocket déconnecté');
          break;

        case 'reconnect_needed':
          _scheduleReconnect();
          break;

        case 'max_reconnect_reached':
          state = state.copyWith(
            isConnected: false,
            error:
                'Impossible de se connecter au serveur. Vérifiez votre connexion.',
          );
          break;

        case 'network_error':
          state = state.copyWith(
            isConnected: false,
            error: 'Erreur réseau. Vérifiez votre connexion internet.',
          );
          break;

        default:
          log('Message WebSocket non géré: ${message['type']}');
      }
    } catch (e) {
      log('❌ Erreur traitement message WebSocket: $e');
    }
  }

  void _handleWalletUpdate(Map<String, dynamic>? data, bool forceUpdate) {
    try {
      if (data == null) return;

      // Vérifier si c'est vraiment une nouvelle donnée ou un force update
      if (!forceUpdate && _isDuplicateWalletData(data)) {
        log('⚠️ Données wallet identiques ignorées');
        return;
      }

      final updatedWallet = WalletModel.fromJson(data);
      state = state.copyWith(wallet: updatedWallet, clearError: true);

      // Mettre à jour le cache
      _lastWalletDataFromWS = Map.from(data);
      _lastUpdateTime = DateTime.now();

      log(
        '💰 Solde mis à jour via WebSocket: ${updatedWallet.formattedBalance}',
      );

      // Si c'est un force update, notifier explicitement
      if (forceUpdate) {
        log('🔄 Force update wallet appliqué');
      }
    } catch (e) {
      log('❌ Erreur mise à jour wallet: $e');
    }
  }

  bool _isDuplicateWalletData(Map<String, dynamic> newData) {
    if (_lastWalletDataFromWS == null) return false;

    try {
      final newBalance = newData['balance']?.toString();
      final newTimestamp =
          newData['updated_at']?.toString() ??
          newData['last_updated']?.toString();

      final oldBalance = _lastWalletDataFromWS!['balance']?.toString();
      final oldTimestamp =
          _lastWalletDataFromWS!['updated_at']?.toString() ??
          _lastWalletDataFromWS!['last_updated']?.toString();

      // Vérifier si les données ont vraiment changé
      final isDuplicate =
          (newBalance == oldBalance) && (newTimestamp == oldTimestamp);

      // Aussi vérifier le temps écoulé (éviter les doublons récents)
      if (isDuplicate && _lastUpdateTime != null) {
        final timeDiff = DateTime.now().difference(_lastUpdateTime!);
        return timeDiff.inSeconds < 2; // Ignorer si moins de 2 secondes
      }

      return isDuplicate;
    } catch (e) {
      log('❌ Erreur vérification doublons: $e');
      return false; // En cas d'erreur, traiter comme non-dupliqué
    }
  }

  void _handleNewTransaction(Map<String, dynamic>? data) {
    try {
      if (data == null) return;

      final newTransaction = TransactionModel.fromJson(data);

      // Vérifier que la transaction n'existe pas déjà
      final existingTransactionIndex = state.transactions.indexWhere(
        (t) => t.uuid == newTransaction.uuid,
      );

      if (existingTransactionIndex >= 0) {
        log('⚠️ Transaction déjà présente, ignorée: ${newTransaction.uuid}');
        return;
      }

      final updatedTransactions = [newTransaction, ...state.transactions];

      state = state.copyWith(
        transactions: updatedTransactions,
        clearError: true,
      );

      log('💸 Nouvelle transaction: ${newTransaction.displayTitle}');

      // Demander une mise à jour du wallet pour synchroniser le solde
      Future.delayed(Duration(milliseconds: 1000), () {
        if (_webSocketService.isConnected) {
          _webSocketService.requestWalletUpdate(forceRefresh: true);
        }
      });
    } catch (e) {
      log('❌ Erreur nouvelle transaction: $e');
    }
  }

  void _handleBalanceChange(Map<String, dynamic> data) {
    if (state.wallet != null) {
      try {
        final newBalance =
            (data['balance'] ?? data['new_balance'] ?? 0.0).toDouble();
        final updatedWallet = state.wallet!.copyWith(
          balance: newBalance,
          updatedAt: DateTime.now(),
        );

        state = state.copyWith(wallet: updatedWallet);
        log('💰 Balance changée: ${updatedWallet.formattedBalance}');
      } catch (e) {
        log('❌ Erreur changement balance: $e');
      }
    }
  }

  void _handleForceRefresh(Map<String, dynamic>? data) {
    log('🔄 Force refresh reçu - rechargement des données');

    // Nettoyer le cache
    _lastWalletDataFromWS = null;
    _lastUpdateTime = null;

    // Recharger les données
    loadWalletData(forceRefresh: true);
  }

  void _handlePinRequired(Map<String, dynamic>? data) {
    log('🔐 PIN requis pour accéder au wallet');
    state = state.copyWith(
      error: 'Authentification PIN requise pour accéder au portefeuille',
      requiresPinAuth: true,
    );
  }

  void _handleConnectionError(String? message) {
    state = state.copyWith(
      isConnected: false,
      error: message ?? 'Erreur de connexion WebSocket',
    );
  }

  void _handleAuthenticationFailed() {
    log('🔐 Authentification WebSocket échouée');
    state = state.copyWith(
      isConnected: false,
      error: 'Authentification échouée. Reconnectez-vous.',
      requiresPinAuth: true,
    );
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      try {
        log('🔄 Tentative de reconnexion WebSocket...');
        final isAuthenticated = await _checkAuthentication();

        if (isAuthenticated) {
          final accessToken = await _authService.getAccessToken();
          if (accessToken != null) {
            final success = await _webSocketService.reconnectWithRetry(
              accessToken,
              maxRetries: 3,
            );

            if (success) {
              state = state.copyWith(isConnected: true);

              // Recharger les données après reconnexion
              await Future.delayed(Duration(milliseconds: 1000));
              await loadWalletData(forceRefresh: true);
            }
          }
        } else {
          log('⚠️ Réauthentification requise pour WebSocket');
          state = state.copyWith(requiresPinAuth: true);
        }
      } catch (e) {
        log('❌ Erreur reconnexion WebSocket: $e');
      }
    });
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (!_webSocketService.isHealthy()) {
        log('⚠️ WebSocket en mauvaise santé, reconnexion...');
        _scheduleReconnect();
      }
    });
  }

  // Méthodes publiques améliorées
  Future<void> loadWalletData({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isAuthenticated = await _checkAuthentication();
      if (!isAuthenticated) {
        throw Exception('Session expirée. Reconnectez-vous.');
      }

      final response = await _walletService.getWalletData();

      if (response != null && response.success) {
        state = state.copyWith(
          wallet: response.wallet,
          transactions: response.transactions ?? [],
          isLoading: false,
          requiresPinAuth: false,
          clearError: true,
        );

        log('✅ Données wallet chargées: ${response.wallet?.formattedBalance}');

        // S'assurer que WebSocket est connecté
        if (!state.isConnected) {
          _scheduleReconnect();
        }
      } else {
        throw Exception(
          response?.message ?? 'Erreur de récupération des données',
        );
      }
    } catch (e) {
      log('❌ Erreur chargement wallet: $e');

      final errorMessage = _getUserFriendlyError(e);
      final requiresPin =
          e.toString().toLowerCase().contains('pin') ||
          e.toString().toLowerCase().contains('auth');

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        requiresPinAuth: requiresPin,
      );
    }
  }

  Future<void> refreshWallet() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, clearError: true);

    try {
      // Méthode 1: Demander via WebSocket d'abord (plus rapide)
      if (_webSocketService.isConnected) {
        log('🔄 Refresh via WebSocket...');
        _webSocketService.requestWalletUpdate(forceRefresh: true);

        // Attendre un peu pour la réponse WebSocket
        await Future.delayed(Duration(seconds: 1));
      }

      // Méthode 2: API REST en parallèle pour double vérification
      log('🔄 Refresh via API...');
      final response = await _walletService.getWalletDataWithFreshToken();

      if (response != null && response.success) {
        // Mettre à jour seulement si les données API sont plus récentes
        final shouldUpdateFromApi = _shouldUpdateFromApiResponse(
          response.wallet,
        );

        if (shouldUpdateFromApi) {
          state = state.copyWith(
            wallet: response.wallet,
            transactions: response.transactions ?? [],
            requiresPinAuth: false,
          );
          log('✅ Wallet rafraîchi via API');
        } else {
          log('✅ Données WebSocket déjà à jour');
        }
      }

      state = state.copyWith(isRefreshing: false);
    } catch (e) {
      log('❌ Erreur refresh wallet: $e');

      final errorMessage = _getUserFriendlyError(e);
      final requiresPin = e.toString().toLowerCase().contains('pin');

      state = state.copyWith(
        isRefreshing: false,
        error: errorMessage,
        requiresPinAuth: requiresPin,
      );

      // En cas d'erreur API, essayer WebSocket en dernier recours
      if (_webSocketService.isConnected) {
        _webSocketService.requestWalletUpdate(forceRefresh: true);
      }
    }
  }

  bool _shouldUpdateFromApiResponse(WalletModel? apiWallet) {
    if (apiWallet == null || state.wallet == null) return true;

    try {
      // Comparer les timestamps de mise à jour
      final apiTimestamp = apiWallet.updatedAt ?? DateTime.now();
      final currentTimestamp =
          state.wallet!.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return apiTimestamp.isAfter(currentTimestamp) ||
          apiWallet.balance != state.wallet!.balance;
    } catch (e) {
      log('❌ Erreur comparaison timestamps: $e');
      return true; // En cas d'erreur, mettre à jour quand même
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Erreur réseau. Vérifiez votre connexion.';
    } else if (errorString.contains('timeout')) {
      return 'Délai d\'attente dépassé. Réessayez.';
    } else if (errorString.contains('pin') || errorString.contains('auth')) {
      return 'Authentification requise';
    } else if (errorString.contains('token') ||
        errorString.contains('unauthorized')) {
      return 'Session expirée. Reconnectez-vous.';
    } else if (errorString.contains('server')) {
      return 'Erreur serveur. Réessayez plus tard.';
    } else {
      return 'Erreur inconnue. Contactez le support.';
    }
  }

  Future<void> forceReconnect() async {
    try {
      log('🔄 Reconnexion forcée...');

      await _webSocketService.disconnect();
      final refreshed = await _authService.refreshAuthToken();

      if (!refreshed) {
        throw Exception('Impossible de rafraîchir l\'authentification');
      }

      await Future.delayed(Duration(seconds: 1));
      await _initializeWebSocket();
      await loadWalletData(forceRefresh: true);

      log('✅ Reconnexion forcée réussie');
    } catch (e) {
      log('❌ Erreur reconnexion forcée: $e');
      state = state.copyWith(
        error: 'Erreur de reconnexion. Redémarrez l\'application.',
        isConnected: false,
      );
    }
  }

  // Méthode pour forcer une mise à jour après changement d'onglet
  Future<void> onTabFocused() async {
    log('👀 Onglet wallet focalisé');

    if (_webSocketService.isConnected) {
      // Demander une mise à jour fraîche
      _webSocketService.requestWalletUpdate(forceRefresh: true);
    } else {
      // Si WebSocket déconnecté, recharger via API
      await refreshWallet();
    }
  }

  // Autres méthodes inchangées mais avec logs améliorés
  Future<void> loadTransactionHistory() async {
    try {
      if (state.isConnected) {
        _webSocketService.requestTransactionsHistory();
      }

      final response = await _walletService.getTransactionHistory();

      if (response != null && response.success) {
        state = state.copyWith(
          transactions: response.transactions ?? [],
          clearError: true,
        );
        log(
          '✅ Historique chargé: ${response.transactions?.length ?? 0} transactions',
        );
      }
    } catch (e) {
      log('❌ Erreur chargement historique: $e');
      state = state.copyWith(error: _getUserFriendlyError(e));
    }
  }

  Future<void> retryAfterPinAuth() async {
    state = state.copyWith(requiresPinAuth: false, clearError: true);
    await Future.delayed(Duration(milliseconds: 500));
    await loadWalletData(forceRefresh: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true, requiresPinAuth: false);
  }

  void clearWallet() {
    state = WalletState();
    _lastWalletDataFromWS = null;
    _lastUpdateTime = null;
    log('🧹 Données wallet nettoyées');
  }

  // Getters
  bool get hasWallet => state.hasWallet;
  bool get isWebSocketConnected => state.isConnected;
  double get currentBalance => state.balance;
  bool get requiresPinAuth => state.requiresPinAuth;

  @override
  void dispose() {
    log('🧹 Nettoyage WalletNotifier...');
    _webSocketSubscription?.cancel();
    _reconnectTimer?.cancel();
    _healthCheckTimer?.cancel();
    _retryTimer?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}
