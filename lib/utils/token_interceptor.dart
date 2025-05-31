import 'dart:convert';
import 'dart:developer';

import 'package:akiba/services/navigation_service/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  bool _isRefreshing = false;

  TokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ⭐ Ne jamais intercepter les appels de refresh
    if (err.requestOptions.path.contains('/token/refresh/')) {
      log('⚠️ Erreur sur refresh token - transmission directe');
      return handler.next(err);
    }

    // ⭐ Ne jamais intercepter les appels de background (updateBackgroundTime)
    if (err.requestOptions.path.contains('/update-background-time/')) {
      log('⚠️ Erreur sur background time - pas critique, on continue');
      return handler.next(err);
    }

    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        log('🔄 401 détecté - vérification refresh token...');

        final refreshToken = await storage.read(key: 'refresh_token');
        if (refreshToken == null || refreshToken.isEmpty) {
          log('❌ Pas de refresh token - fin de session');
          await _handleLogout();
          return handler.reject(err);
        }

        // ⭐ Vérifier si le refresh token n'est pas expiré avant de l'utiliser
        if (_isTokenExpired(refreshToken)) {
          log('❌ Refresh token expiré - fin de session');
          await _handleLogout();
          return handler.reject(err);
        }

        log('🔄 Refresh token valide - tentative de refresh...');

        // Utiliser une instance Dio séparée pour éviter les boucles
        final refreshDio = Dio();
        refreshDio.options = BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        final response = await refreshDio.post(
          '/accounts/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final newAccessToken = response.data['access'];
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await storage.write(key: 'access_token', value: newAccessToken);
          dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

          log('✅ Token refreshed successfully - retrying original request');

          // Rejouer la requête originale
          final clonedRequest = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: {...dio.options.headers, ...?err.requestOptions.headers},
            ),
          );

          return handler.resolve(clonedRequest);
        } else {
          log('❌ Réponse refresh invalide');
          await _handleLogout();
          return handler.reject(err);
        }
      } catch (refreshError) {
        log('❌ Erreur lors du refresh: $refreshError');

        // ⭐ Seulement supprimer les tokens si le refresh token est vraiment invalide
        if (refreshError is DioException &&
            refreshError.response?.statusCode == 401) {
          final errorData = refreshError.response?.data;
          if (errorData != null &&
              errorData['detail']?.toString().contains('blacklisted') == true) {
            log('🔴 Refresh token blacklisted - déconnexion forcée');
            await _handleLogout();
          } else {
            log(
              '⚠️ Erreur 401 sur refresh mais pas blacklisted - conservation des tokens',
            );
          }
        }

        return handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            error: 'Session expirée. Veuillez vous reconnecter.',
            type: DioExceptionType.badResponse,
          ),
        );
      } finally {
        _isRefreshing = false;
      }
    } else {
      return handler.next(err);
    }
  }

  // ⭐ Méthode locale pour vérifier l'expiration des tokens
  bool _isTokenExpired(String token) {
    try {
      if (token.isEmpty || token.split('.').length != 3) {
        return true;
      }

      final parts = token.split('.');
      final payload = parts[1];

      // Ajouter le padding manquant si nécessaire
      var normalized = payload;
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }

      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded);

      final exp = data['exp'];
      if (exp == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now().add(
        const Duration(seconds: 30),
      ); // Marge de 30s

      return expiryDate.isBefore(now);
    } catch (e) {
      log('❌ Erreur vérification token: $e');
      return true;
    }
  }

  Future<void> _handleLogout() async {
    try {
      await storage.deleteAll();
      dio.options.headers.remove('Authorization');
      log('🔴 Tokens supprimés - redirection login');
      _redirectToLogin();
    } catch (e) {
      log('❌ Erreur lors de la déconnexion: $e');
    }
  }

  void _redirectToLogin() {
    NavigationService.navigateToLogin();
  }
}
