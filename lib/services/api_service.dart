// lib/services/api_service.dart
import 'dart:developer';

import 'package:akiba/utils/token_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl =
      'https://trusty-awaited-chow.ngrok-free.app/api';
  // static const String baseUrl = 'http://192.168.101.253:8000/api';

  final Dio _dio = Dio();

  ApiService() {
    // _dio.interceptors.add(
    //   InterceptorsWrapper(
    //     onRequest: (options, handler) {
    //       options.headers['ngrok-skip-browser-warning'] = 'true';
    //       options.headers['User-Agent'] = 'AkibaApp/1.0';
    //       handler.next(options);
    //     },
    //   ),
    // );
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Intercepteur pour logs (uniquement en debug)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }

    _dio.interceptors.add(TokenInterceptor(_dio));
  }

  Dio get dio => _dio;

  String get currentBaseUrl => _dio.options.baseUrl;

  // Setter pour le token JWT
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Supprimer le token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Méthodes HTTP génériques
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      log("Dio Exception: $e");
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // ? === ENDPOINTS D'AUTHENTIFICATION ===

  // Étape 1: Inscription initiale
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String password,
  }) async {
    return await post('/accounts/register/', {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'password': password,
    });
  }

  // Étape 2: Vérification du code SMS
  Future<Map<String, dynamic>> verifyPhone({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    return await post('/accounts/verify-phone/', {
      'phone_number': phoneNumber,
      'verification_code': verificationCode,
    });
  }

  // Étape 3: Créer le code PIN
  Future<Map<String, dynamic>> createPin({
    required String pinCode,
    required String confirmPinCode,
  }) async {
    return await post('/accounts/create-pin/', {
      'pin_code': pinCode,
      'confirm_pin_code': confirmPinCode,
    });
  }

  // Vérifier le code PIN
  Future<Map<String, dynamic>> verifyPin({required String pinCode}) async {
    return await post('/accounts/verify-pin/', {'pin_code': pinCode});
  }

  // Renvoyer le code de vérification
  Future<Map<String, dynamic>> resendCode({required String phoneNumber}) async {
    return await post('/accounts/resend-code/', {'phone_number': phoneNumber});
  }

  // Connexion
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    return await post('/accounts/login/', {
      'phone_number': phoneNumber,
      'password': password,
    });
  }

  // Profil utilisateur
  Future<Map<String, dynamic>> getUserProfile() async {
    return await get('/accounts/profile/');
  }

  Future<Map<String, dynamic>> getAuthStatus({required String token}) async {
    try {
      setAuthToken(token);

      // 🔍 DEBUG: Vérifier l'URL complète
      final fullUrl = '${_dio.options.baseUrl}/accounts/auth-status/';
      log('🔍 URL complète pour auth-status: $fullUrl');
      log('🔍 Base URL actuelle: ${_dio.options.baseUrl}');

      final response = await _dio.get('/accounts/auth-status/');
      return response.data;
    } on DioException catch (e) {
      log('❌ URL qui a échoué: ${e.requestOptions.uri}');
      log('❌ Erreur getAuthStatus: ${e.message}');
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateBackgroundTime({
    required String token,
  }) async {
    try {
      setAuthToken(token);

      // 🔍 DEBUG: Vérifier l'URL complète
      final fullUrl =
          '${_dio.options.baseUrl}/accounts/update-background-time/';
      log('🔍 URL complète pour update-background-time: $fullUrl');
      log('🔍 Base URL actuelle: ${_dio.options.baseUrl}');

      final response = await _dio.post('/accounts/update-background-time/');
      return response.data;
    } on DioException catch (e) {
      log('❌ URL qui a échoué: ${e.requestOptions.uri}');
      log('❌ Erreur updateBackgroundTime: ${e.message}');
      throw _handleDioException(e);
    }
  }

  // Gestion des erreurs Dio
  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connexion lente. Vérifiez votre connexion internet.';

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;

        if (statusCode == 400 && data is Map<String, dynamic>) {
          // Erreur de validation Django
          if (data['success'] == false) {
            return data['message'] ?? 'Erreur de validation';
          }
          // Erreurs de champs
          if (data['errors'] != null) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
        }

        switch (statusCode) {
          case 400:
            return 'Données invalides';
          case 401:
            return 'Session expirée. Veuillez vous reconnecter.';
          case 403:
            return 'Accès refusé';
          case 404:
            return 'Service non trouvé';
          case 500:
            return 'Erreur serveur. Réessayez plus tard.';
          default:
            return 'Erreur réseau (${statusCode ?? 'Inconnue'})';
        }

      case DioExceptionType.cancel:
        return 'Requête annulée';

      case DioExceptionType.unknown:
      default:
        if (e.message?.contains('SocketException') == true) {
          return 'Pas de connexion internet';
        }
        return 'Erreur inconnue. Réessayez plus tard.';
    }
  }
}
