import 'dart:developer';
import 'package:akiba/models/wallet_models/wallet_response_model.dart';
import 'package:akiba/services/api_service.dart';
import 'package:akiba/services/auth_service/auth_service.dart';

class WalletService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // ⭐ NOUVEAU : Vérifier si PIN requis avant les appels wallet
  Future<bool> _checkPinRequirement() async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) return false;

      _apiService.setAuthToken(accessToken);

      // Vérifier le statut d'authentification
      final authStatus = await _apiService.getAuthStatus(token: accessToken);

      if (authStatus['requires_pin_auth'] == true) {
        log('⚠️ PIN requis avant accès wallet');
        return false; // PIN requis
      }

      return true; // Pas de PIN requis
    } catch (e) {
      log('❌ Erreur vérification PIN: $e');
      return false;
    }
  }

  // Récupérer les données du wallet avec vérification PIN
  Future<WalletResponseModel?> getWalletData() async {
    try {
      // ⭐ Vérifier d'abord si PIN requis
      final pinOk = await _checkPinRequirement();
      if (!pinOk) {
        throw Exception('Authentification PIN requise');
      }

      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      // ⭐ S'assurer que le token est frais
      if (_authService.isTokenExpired(accessToken)) {
        log('⚠️ Token expiré dans getWalletData, tentative refresh...');
        final refreshed = await _authService.refreshAuthToken();
        if (!refreshed) {
          throw Exception('Impossible de rafraîchir le token');
        }
      }

      final freshToken = await _authService.getAccessToken();
      if (freshToken == null) {
        throw Exception('Token non disponible après refresh');
      }

      _apiService.setAuthToken(freshToken);

      // ⭐ Ajouter un délai pour éviter les race conditions
      await Future.delayed(const Duration(milliseconds: 50));

      final response = await _apiService.get('/wallet/');
      return WalletResponseModel.fromJson(response);
    } catch (e) {
      log('❌ Erreur getWalletData: $e');
      rethrow;
    }
  }

  // ⭐ NOUVEAU : Méthode pour rafraîchir explicitement le token avant appel
  Future<WalletResponseModel?> getWalletDataWithFreshToken() async {
    try {
      // Forcer un refresh du token
      log('🔄 Refresh explicite du token avant appel wallet...');
      final refreshed = await _authService.refreshAuthToken();

      if (!refreshed) {
        throw Exception('Impossible de rafraîchir le token');
      }

      // Attendre un peu pour s'assurer que le token est bien sauvé
      await Future.delayed(const Duration(milliseconds: 200));

      return await getWalletData();
    } catch (e) {
      log('❌ Erreur getWalletDataWithFreshToken: $e');
      rethrow;
    }
  }

  // Récupérer l'historique des transactions
  Future<WalletResponseModel?> getTransactionHistory({
    int? limit,
    int? offset,
    String? transactionType,
  }) async {
    try {
      // Vérifier PIN
      final pinOk = await _checkPinRequirement();
      if (!pinOk) {
        throw Exception('Authentification PIN requise');
      }

      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      _apiService.setAuthToken(accessToken);

      String endpoint = '/wallet/transactions/';
      List<String> queryParams = [];

      if (limit != null) queryParams.add('limit=$limit');
      if (offset != null) queryParams.add('offset=$offset');
      if (transactionType != null) queryParams.add('type=$transactionType');

      if (queryParams.isNotEmpty) {
        endpoint += '?${queryParams.join('&')}';
      }

      final response = await _apiService.get(endpoint);
      return WalletResponseModel.fromJson(response);
    } catch (e) {
      log('❌ Erreur getTransactionHistory: $e');
      rethrow;
    }
  }

  // Effectuer un dépôt
  Future<WalletResponseModel?> makeDeposit({
    required double amount,
    required String operator,
    String? reference,
  }) async {
    try {
      final pinOk = await _checkPinRequirement();
      if (!pinOk) {
        throw Exception('Authentification PIN requise');
      }

      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      _apiService.setAuthToken(accessToken);

      final response = await _apiService.post('/wallet/deposit/', {
        'amount': amount,
        'operator': operator,
        if (reference != null) 'reference': reference,
      });

      return WalletResponseModel.fromJson(response);
    } catch (e) {
      log('❌ Erreur makeDeposit: $e');
      rethrow;
    }
  }

  // Effectuer un retrait
  Future<WalletResponseModel?> makeWithdrawal({
    required double amount,
    required String operator,
    String? reference,
  }) async {
    try {
      final pinOk = await _checkPinRequirement();
      if (!pinOk) {
        throw Exception('Authentification PIN requise');
      }

      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      _apiService.setAuthToken(accessToken);

      final response = await _apiService.post('/wallet/withdraw/', {
        'amount': amount,
        'operator': operator,
        if (reference != null) 'reference': reference,
      });

      return WalletResponseModel.fromJson(response);
    } catch (e) {
      log('❌ Erreur makeWithdrawal: $e');
      rethrow;
    }
  }

  // Effectuer un transfert
  Future<WalletResponseModel?> makeTransfer({
    required String receiverPhoneNumber,
    required double amount,
    String? message,
  }) async {
    try {
      final pinOk = await _checkPinRequirement();
      if (!pinOk) {
        throw Exception('Authentification PIN requise');
      }

      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Token d\'accès non trouvé');
      }

      _apiService.setAuthToken(accessToken);

      final response = await _apiService.post('/wallet/transfer/', {
        'receiver_phone': receiverPhoneNumber,
        'amount': amount,
        if (message != null) 'message': message,
      });

      log("Response Make Transfert: $response");

      return WalletResponseModel.fromJson(response);
    } catch (e) {
      log('❌ Erreur makeTransfer: $e');
      rethrow;
    }
  }

  // Vérifier le solde en temps réel
  Future<double?> checkBalance() async {
    try {
      final walletData = await getWalletData();
      return walletData?.wallet?.balance;
    } catch (e) {
      log('❌ Erreur checkBalance: $e');
      return null;
    }
  }
}

// class WalletService {
//   final ApiService _apiService = ApiService();
//   final AuthService _authService = AuthService();

//   // Récupérer les données du wallet
//   Future<WalletResponseModel?> getWalletData() async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken == null) {
//         throw Exception('Token d\'accès non trouvé');
//       }

//       _apiService.setAuthToken(accessToken);
//       final response = await _apiService.get('/wallet/');

//       return WalletResponseModel.fromJson(response);
//     } catch (e) {
//       log('❌ Erreur getWalletData: $e');
//       rethrow;
//     }
//   }

//   // Récupérer l'historique des transactions
//   Future<WalletResponseModel?> getTransactionHistory({
//     int? limit,
//     int? offset,
//     String? transactionType,
//   }) async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken == null) {
//         throw Exception('Token d\'accès non trouvé');
//       }

//       _apiService.setAuthToken(accessToken);

//       String endpoint = '/wallet/transactions/';
//       List<String> queryParams = [];

//       if (limit != null) queryParams.add('limit=$limit');
//       if (offset != null) queryParams.add('offset=$offset');
//       if (transactionType != null) queryParams.add('type=$transactionType');

//       if (queryParams.isNotEmpty) {
//         endpoint += '?${queryParams.join('&')}';
//       }

//       final response = await _apiService.get(endpoint);
//       return WalletResponseModel.fromJson(response);
//     } catch (e) {
//       log('❌ Erreur getTransactionHistory: $e');
//       rethrow;
//     }
//   }

//   // Effectuer un dépôt
//   Future<WalletResponseModel?> makeDeposit({
//     required double amount,
//     required String operator,
//     String? reference,
//   }) async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken == null) {
//         throw Exception('Token d\'accès non trouvé');
//       }

//       _apiService.setAuthToken(accessToken);

//       final response = await _apiService.post('/wallet/deposit/', {
//         'amount': amount,
//         'operator': operator,
//         if (reference != null) 'reference': reference,
//       });

//       return WalletResponseModel.fromJson(response);
//     } catch (e) {
//       log('❌ Erreur makeDeposit: $e');
//       rethrow;
//     }
//   }

//   // Effectuer un retrait
//   Future<WalletResponseModel?> makeWithdrawal({
//     required double amount,
//     required String operator,
//     String? reference,
//   }) async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken == null) {
//         throw Exception('Token d\'accès non trouvé');
//       }

//       _apiService.setAuthToken(accessToken);

//       final response = await _apiService.post('/wallet/withdraw/', {
//         'amount': amount,
//         'operator': operator,
//         if (reference != null) 'reference': reference,
//       });

//       return WalletResponseModel.fromJson(response);
//     } catch (e) {
//       log('❌ Erreur makeWithdrawal: $e');
//       rethrow;
//     }
//   }

//   // Effectuer un transfert
//   Future<WalletResponseModel?> makeTransfer({
//     required String receiverPhoneNumber,
//     required double amount,
//     String? message,
//   }) async {
//     try {
//       final accessToken = await _authService.getAccessToken();
//       if (accessToken == null) {
//         throw Exception('Token d\'accès non trouvé');
//       }

//       _apiService.setAuthToken(accessToken);

//       final response = await _apiService.post('/wallet/transfer/', {
//         'receiver_phone': receiverPhoneNumber,
//         'amount': amount,
//         if (message != null) 'message': message,
//       });

//       return WalletResponseModel.fromJson(response);
//     } catch (e) {
//       log('❌ Erreur makeTransfer: $e');
//       rethrow;
//     }
//   }

//   // Vérifier le solde en temps réel
//   Future<double?> checkBalance() async {
//     try {
//       final walletData = await getWalletData();
//       return walletData?.wallet?.balance;
//     } catch (e) {
//       log('❌ Erreur checkBalance: $e');
//       return null;
//     }
//   }
// }
