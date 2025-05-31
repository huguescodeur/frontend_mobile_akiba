import 'dart:developer';

import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/services/api_service.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/services/navigation_service/navigation_service.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/auth/register/create_pin_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';

import 'dart:developer';

import 'package:akiba/models/auth_status_model.dart';

import 'package:akiba/views/home/accueil_view.dart';

import 'package:flutter/material.dart';

class LifecycleHandler extends WidgetsBindingObserver {
  // Singleton pattern
  static LifecycleHandler? _instance;

  LifecycleHandler._internal();

  static LifecycleHandler get instance {
    _instance ??= LifecycleHandler._internal();
    return _instance!;
  }

  bool _isRefreshing = false;
  DateTime? _lastPauseTime;
  static const int pinTimeoutMinutes = 1; // Configurez selon vos besoins
  BuildContext? _context;

  // Méthode pour définir le context
  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_isRefreshing) return;

    final authService = AuthService();

    switch (state) {
      case AppLifecycleState.resumed:
        log('[LIFECYCLE] App resumed');
        await _handleAppResume(authService);
        break;

      case AppLifecycleState.paused:
        log('[LIFECYCLE] App paused');
        _lastPauseTime = DateTime.now();
        await _handleAppPause(authService);
        break;

      case AppLifecycleState.inactive:
        log('[LIFECYCLE] App inactive');
        // Ne pas traiter inactive comme paused car c'est transitoire
        break;

      case AppLifecycleState.detached:
        log('[LIFECYCLE] App detached');
        break;

      case AppLifecycleState.hidden:
        log('[LIFECYCLE] App hidden');
        if (_lastPauseTime == null) {
          _lastPauseTime = DateTime.now();
        }
        break;
    }
  }

  Future<void> _handleAppResume(AuthService authService) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      log('🔍 === RESUME APP - VÉRIFICATION STATUT ===');

      // ⭐ Vérifier si on doit demander le PIN
      if (_lastPauseTime != null) {
        final timeDiff = DateTime.now().difference(_lastPauseTime!);
        log('⏱️ Temps hors app: ${timeDiff.inMinutes} minutes');

        if (timeDiff.inMinutes >= pinTimeoutMinutes) {
          log('🔒 Temps dépassé - Vérification statut pour PIN');
          await _handlePinTimeoutNavigation(authService);
          return;
        }
      }

      // ⭐ Vérification des tokens
      final token = await authService.getAccessToken();
      final refreshToken = await authService.getRefreshToken();

      // ⭐ Vérification de base des tokens
      if (token == null || refreshToken == null) {
        log('❌ Pas de tokens - redirection login');
        await authService.clearTokens();
        _redirectToLogin();
        return;
      }

      // ⭐ Si access token valide, on continue normalement
      if (!authService.isTokenExpired(token)) {
        log('✅ Access token valide - aucune action nécessaire');
        return;
      }

      // ⭐ Access token expiré, vérifier le refresh token
      log('⚠️ Access token expiré - vérification refresh token');

      if (authService.isTokenExpired(refreshToken)) {
        log('🔴 Refresh token aussi expiré - déconnexion');
        await authService.clearTokens();
        _redirectToLogin();
        return;
      }

      // ⭐ Tentative de refresh
      log('🔄 Tentative de refresh du token...');
      final refreshSuccess = await authService.refreshAuthToken();

      if (refreshSuccess) {
        log('✅ Refresh réussi - session maintenue');
      } else {
        log('🔴 Échec du refresh - déconnexion');
        await authService.clearTokens();
        _redirectToLogin();
      }
    } catch (e) {
      log('❌ Erreur handleAppResume: $e');
      // En cas d'erreur critique, on laisse l'utilisateur dans l'app
      // mais on log l'erreur pour debugging
    } finally {
      _isRefreshing = false;
      _lastPauseTime = null; // Reset après traitement
    }
  }

  Future<void> _handleAppPause(AuthService authService) async {
    try {
      log('⏸️ App mise en pause - sauvegarde état');

      final token = await authService.getAccessToken();
      if (token != null && !authService.isTokenExpired(token)) {
        try {
          final apiService = ApiService();
          await apiService.updateBackgroundTime(token: token);
          log('✅ Background time updated');
        } catch (e) {
          log('⚠️ Erreur update background time: $e (non critique)');
          // Ne pas échouer si updateBackgroundTime échoue
        }
      } else {
        log('⚠️ Token invalide - pas de update background time');
      }
    } catch (e) {
      log('❌ Erreur handleAppPause: $e');
    }
  }

  // ⭐ Nouvelle méthode pour gérer le timeout PIN avec la même logique que SplashView
  Future<void> _handlePinTimeoutNavigation(AuthService authService) async {
    try {
      log('🔒 Gestion timeout PIN - vérification statut auth');

      final authStatus = await authService.checkAuthStatus();

      if (_context != null && _context!.mounted) {
        _navigateBasedOnStatus(authStatus);
      } else {
        log('⚠️ Context non disponible pour navigation PIN');
        // Fallback vers NavigationService
        _redirectToLogin();
      }
    } catch (e) {
      log('❌ Erreur handlePinTimeoutNavigation: $e');
      // En cas d'erreur, rediriger vers login par sécurité
      _redirectToLogin();
    }
  }

  // ⭐ Même logique de navigation que SplashView
  void _navigateBasedOnStatus(AuthStatusModel status) {
    if (_context == null || !_context!.mounted) {
      log('⚠️ Context non valide pour navigation');
      return;
    }

    log('📍 Navigation basée sur le statut: $status');
    log('📍 Has Pin Code: ${status.hasPinCode}');
    log('📍 Is Auth: ${status.isAuthenticated}');
    log('📍 Is First Time: ${status.isFirstTime}');
    log('📍 Required Pin Auth: ${status.requiredPinAuth}');

    if (status.isAuthenticated &&
        status.hasPinCode &&
        !status.requiredPinAuth) {
      // Utilisateur connecté avec PIN valide - aller à l'accueil
      log('✅ Utilisateur authentifié - redirection vers accueil');
      navigateWithTransition(
        context: _context!,
        page: const AccueilView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else if (status.isAuthenticated &&
        status.hasPinCode &&
        status.requiredPinAuth) {
      // Utilisateur connecté mais PIN requis
      log('🔒 PIN requis - redirection vers vérification PIN');
      navigateWithTransition(
        context: _context!,
        page: const VerifyPinView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else if (status.isAuthenticated && !status.hasPinCode) {
      // Utilisateur connecté mais pas de PIN configuré
      log('🔧 PIN manquant - redirection vers création PIN');
      navigateWithTransition(
        context: _context!,
        page: const CreatePinView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else {
      // Utilisateur non connecté
      log('❌ Utilisateur non authentifié - redirection vers login');
      navigateWithTransition(
        context: _context!,
        page: LoginView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    }
  }

  void _redirectToLogin() {
    try {
      if (_context != null && _context!.mounted) {
        log('🔄 Redirection login avec context');
        navigateWithTransition(
          context: _context!,
          page: LoginView(),
          direction: TransitionDirection.rightToLeft,
          replace: true,
        );
      } else {
        // Fallback vers NavigationService si pas de context
        log('🔄 Redirection login avec NavigationService (fallback)');
        NavigationService.navigateToLogin();
      }
    } catch (e) {
      log('❌ Erreur redirection login: $e');
      // Dernier recours avec NavigationService
      try {
        NavigationService.navigateToLogin();
      } catch (fallbackError) {
        log('❌ Erreur fallback navigation: $fallbackError');
      }
    }
  }

  // Méthode utilitaire pour débugger l'état du handler
  void debugStatus() {
    log('=== LIFECYCLE HANDLER DEBUG ===');
    log('Context disponible: ${_context != null}');
    log('Context mounted: ${_context?.mounted ?? false}');
    log('Is refreshing: $_isRefreshing');
    log('Last pause time: $_lastPauseTime');
    log('Pin timeout minutes: $pinTimeoutMinutes');
    log('==============================');
  }
}

// class LifecycleHandler extends WidgetsBindingObserver {
//   bool _isRefreshing = false;
//   DateTime? _lastPauseTime;
//   static const int pinTimeoutMinutes = 1; // Configurez selon vos besoins

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (_isRefreshing) return;

//     final authService = AuthService();

//     switch (state) {
//       case AppLifecycleState.resumed:
//         log('[LIFECYCLE] App resumed');
//         await _handleAppResume(authService);
//         break;

//       case AppLifecycleState.paused:
//         log('[LIFECYCLE] App paused');
//         _lastPauseTime = DateTime.now();
//         await _handleAppPause(authService);
//         break;

//       case AppLifecycleState.inactive:
//         log('[LIFECYCLE] App inactive');
//         // Ne pas traiter inactive comme paused car c'est transitoire
//         break;

//       case AppLifecycleState.detached:
//         log('[LIFECYCLE] App detached');
//         break;

//       case AppLifecycleState.hidden:
//         log('[LIFECYCLE] App hidden');
//         if (_lastPauseTime == null) {
//           _lastPauseTime = DateTime.now();
//         }
//         break;
//     }
//   }

//   Future<void> _handleAppResume(AuthService authService) async {
//     if (_isRefreshing) return;
//     _isRefreshing = true;

//     try {
//       log('🔍 === RESUME APP - VÉRIFICATION STATUT ===');

//       // ⭐ Vérifier si on doit demander le PIN
//       if (_lastPauseTime != null) {
//         final timeDiff = DateTime.now().difference(_lastPauseTime!);
//         log('⏱️ Temps hors app: ${timeDiff.inMinutes} minutes');

//         if (timeDiff.inMinutes >= pinTimeoutMinutes) {
//           log('🔒 Temps dépassé - PIN requis');
//           // Rediriger vers PIN verification si nécessaire
//           _handlePinTimeout();
//           return;
//         }
//       }

//       final token = await authService.getAccessToken();
//       final refreshToken = await authService.getRefreshToken();

//       // ⭐ Vérification de base des tokens
//       if (token == null || refreshToken == null) {
//         log('❌ Pas de tokens - redirection login');
//         await authService.clearTokens();
//         _redirectToLogin();
//         return;
//       }

//       // ⭐ Si access token valide, on continue normalement
//       if (!authService.isTokenExpired(token)) {
//         log('✅ Access token valide - aucune action nécessaire');
//         return;
//       }

//       // ⭐ Access token expiré, vérifier le refresh token
//       log('⚠️ Access token expiré - vérification refresh token');

//       if (authService.isTokenExpired(refreshToken)) {
//         log('🔴 Refresh token aussi expiré - déconnexion');
//         await authService.clearTokens();
//         _redirectToLogin();
//         return;
//       }

//       // ⭐ Tentative de refresh
//       log('🔄 Tentative de refresh du token...');
//       final refreshSuccess = await authService.refreshAuthToken();

//       if (refreshSuccess) {
//         log('✅ Refresh réussi - session maintenue');
//       } else {
//         log('🔴 Échec du refresh - déconnexion');
//         await authService.clearTokens();
//         _redirectToLogin();
//       }
//     } catch (e) {
//       log('❌ Erreur handleAppResume: $e');
//       // En cas d'erreur critique, on laisse l'utilisateur dans l'app
//       // mais on log l'erreur pour debugging
//     } finally {
//       _isRefreshing = false;
//       _lastPauseTime = null; // Reset après traitement
//     }
//   }

//   Future<void> _handleAppPause(AuthService authService) async {
//     try {
//       log('⏸️ App mise en pause - sauvegarde état');

//       final token = await authService.getAccessToken();
//       if (token != null && !authService.isTokenExpired(token)) {
//         try {
//           final apiService = ApiService();
//           await apiService.updateBackgroundTime(token: token);
//           log('✅ Background time updated');
//         } catch (e) {
//           log('⚠️ Erreur update background time: $e (non critique)');
//           // Ne pas échouer si updateBackgroundTime échoue
//         }
//       } else {
//         log('⚠️ Token invalide - pas de update background time');
//       }
//     } catch (e) {
//       log('❌ Erreur handleAppPause: $e');
//     }
//   }

//   void _handlePinTimeout() {
//     // Implémentez selon votre logique de PIN
//     // Exemple :
//     // NavigationService.navigateToVerifyPin();
//     log('🔒 Redirection vers vérification PIN');
//   }

//   void _redirectToLogin() {
//     try {
//       NavigationService.navigateToLogin();
//     } catch (e) {
//       log('❌ Erreur redirection login: $e');
//     }
//   }
// }

// class LifecycleHandler extends WidgetsBindingObserver {
//   bool _isRefreshing =
//       false; // ⭐ Ajout d'un flag pour éviter les appels multiples

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (_isRefreshing) return; // ⭐ Éviter les appels simultanés

//     final authService = AuthService();

//     switch (state) {
//       case AppLifecycleState.resumed:
//         log('[LIFECYCLE] App resumed');
//         await _handleAppResume(authService);
//         break;
//       case AppLifecycleState.paused:
//       case AppLifecycleState.inactive:
//         log('[LIFECYCLE] App paused/inactive ($state)');
//         await _handleAppPause(authService);
//         break;
//       case AppLifecycleState.detached:
//         log('[LIFECYCLE] App detached');
//         break;
//       case AppLifecycleState.hidden:
//         log('[LIFECYCLE] App hidden');
//         break;
//     }
//   }

//   Future<void> _handleAppResume(AuthService authService) async {
//     if (_isRefreshing) return;
//     _isRefreshing = true;

//     try {
//       final token = await authService.getAccessToken();
//       final refreshToken = await authService.getRefreshToken();

//       // ⭐ Si pas de tokens, déconnecter immédiatement
//       if (token == null || refreshToken == null) {
//         log('❌ Pas de tokens - utilisateur non connecté');
//         await authService.clearTokens();
//         _redirectToLogin();
//         return;
//       }

//       // ⭐ Si access token valide, tout va bien
//       if (!authService.isTokenExpired(token)) {
//         log('✅ Access token encore valide');
//         return;
//       }

//       log('⚠️ Access token expiré - vérification refresh token');

//       // ⭐ Si refresh token aussi expiré, déconnecter
//       if (authService.isTokenExpired(refreshToken)) {
//         log('🔴 Refresh token aussi expiré - déconnexion');
//         await authService.clearTokens();
//         _redirectToLogin();
//         return;
//       }

//       // ⭐ Tenter le refresh
//       log('🔄 Tentative de refresh token...');
//       final refreshSuccess = await authService.refreshAuthToken();

//       if (!refreshSuccess) {
//         log('🔴 Échec du refresh - déconnexion forcée');
//         await authService.clearTokens();
//         _redirectToLogin();
//         return;
//       }

//       log('✅ Refresh réussi - utilisateur toujours connecté');
//     } catch (e) {
//       log('❌ Erreur handleAppResume: $e');
//       // En cas d'erreur, déconnecter par sécurité
//       await authService.clearTokens();
//       _redirectToLogin();
//     } finally {
//       _isRefreshing = false;
//     }
//   }

//   Future<void> _handleAppPause(AuthService authService) async {
//     final token = await authService.getAccessToken();
//     if (token != null) {
//       try {
//         final apiService = ApiService();
//         await apiService.updateBackgroundTime(token: token);
//       } catch (e) {
//         log('Erreur update background time: $e');
//       }
//     }
//   }

//   void _redirectToLogin() {
//     NavigationService.navigateToLogin();
//   }
// }
