import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/services/api_service.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/services/navigation_service/navigation_service.dart';
import 'package:akiba/services/websocket_service/websocket_service.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/auth/register/create_pin_view.dart';
import 'package:akiba/views/home/home_view.dart';
import 'package:akiba/views/home/main_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';

import 'dart:developer';

import 'package:akiba/models/auth_status_model.dart';

import 'package:akiba/views/home/accueil_view.dart';

import 'package:flutter/material.dart';

// class LifecycleHandler extends WidgetsBindingObserver {
//   // Singleton pattern
//   static LifecycleHandler? _instance;

//   static bool isInRegistrationFlow = false;
//   static bool isInLoginFlow = false;

//   WebSocketService wsService = WebSocketService();

//   LifecycleHandler._internal();

//   static LifecycleHandler get instance {
//     _instance ??= LifecycleHandler._internal();
//     return _instance!;
//   }

//   bool _isRefreshing = false;
//   DateTime? _lastPauseTime;
//   static const int pinTimeoutMinutes = 1; // Configurez selon vos besoins
//   BuildContext? _context;

//   // Méthode pour définir le context
//   void setContext(BuildContext context) {
//     _context = context;
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     if (_isRefreshing) return;

//     final authService = AuthService();

//     switch (state) {
//       case AppLifecycleState.resumed:
//         final timeDiff = DateTime.now().difference(_lastPauseTime!);

//         if (timeDiff.inMinutes >= 1) {
//           log(
//             '⏱️ Pause prolongée (${timeDiff.inMinutes}m) → On redémarre le WebSocket',
//           );

//           final token = await authService.getAccessToken();
//           if (token != null) {
//             final wsService = WebSocketService();
//             await wsService.reconnect(token); // 🔁 reconnexion propre
//           }
//         } else {
//           log('⏱️ Pause courte, pas de reconnexion WebSocket nécessaire');
//         }
//         wsService.requestWalletUpdate();

//         log('[LIFECYCLE] App resumed');
//         await _handleAppResume(authService);
//         break;

//       case AppLifecycleState.paused:
//         log('[LIFECYCLE] App paused');
//         _lastPauseTime = DateTime.now();
//         final wsService = WebSocketService();
//         await wsService.disconnect();
//         await _handleAppPause(authService);
//         break;

//       case AppLifecycleState.inactive:
//         log('[LIFECYCLE] App inactive');

//         final wsService = WebSocketService();
//         await wsService.disconnect();
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

//       // Vérification des tokens en premier
//       final token = await authService.getAccessToken();
//       final refreshToken = await authService.getRefreshToken();

//       if (token == null || refreshToken == null) {
//         if (!wsService.isHealthy()) {
//           log('⚠️ WebSocket non sain - reconnexion...');
//           await wsService.reconnect(token);
//         } else {
//           log('✅ WebSocket OK - pas de reconnexion');
//         }
//         // Vérifier si on est en cours d'inscription
//         if (isInRegistrationFlow) {
//           log('✅ Mode inscription actif - pas de redirection');
//           return;
//         } else if (isInLoginFlow) {
//           log('✅ Mode login actif - pas de redirection');
//           return;
//         }

//         log('❌ Pas de tokens - redirection login');
//         await authService.clearTokens();
//         _redirectToLogin();
//         return;
//       }

//       // Vérifier si l'access token est expiré
//       if (authService.isTokenExpired(token)) {
//         log('⚠️ Access token expiré - tentative de refresh');
//         if (authService.isTokenExpired(refreshToken)) {
//           log('🔴 Refresh token aussi expiré - déconnexion');
//           await authService.clearTokens();
//           _redirectToLogin();
//           return;
//         }

//         final refreshSuccess = await authService.refreshAuthToken();
//         if (!refreshSuccess) {
//           log('🔴 Échec du refresh - déconnexion');
//           await authService.clearTokens();
//           _redirectToLogin();
//           return;
//         }
//       }

//       // MAINTENANT vérifier si on doit demander le PIN
//       if (_lastPauseTime != null) {
//         final timeDiff = DateTime.now().difference(_lastPauseTime!);
//         log('⏱️ Temps hors app: ${timeDiff.inMinutes} minutes');

//         if (timeDiff.inMinutes >= pinTimeoutMinutes) {
//           log('🔒 Temps dépassé - Vérification statut pour PIN');

//           // Forcer une nouvelle vérification du statut depuis le serveur
//           await _handlePinTimeoutNavigation(authService);
//           return;
//         } else {
//           log('✅ Temps OK - pas besoin de PIN');
//         }
//       }

//       log('✅ Reprise normale de l\'app');
//     } catch (e) {
//       log('❌ Erreur handleAppResume: $e');
//     } finally {
//       _isRefreshing = false;
//       _lastPauseTime = null;
//     }
//   }

//   // Améliorer la méthode _handlePinTimeoutNavigation
//   Future<void> _handlePinTimeoutNavigation(AuthService authService) async {
//     try {
//       log('🔒 Gestion timeout PIN - vérification statut auth');

//       // Forcer une requête fresh au serveur (pas de cache)
//       final authStatus = await authService.checkAuthStatus(forceRefresh: true);
//       log('📊 Statut auth reçu: ${authStatus.toString()}');

//       if (_context != null && _context!.mounted) {
//         _navigateBasedOnStatus(authStatus);
//       } else {
//         log('⚠️ Context non disponible pour navigation PIN');
//         _redirectToLogin();
//       }
//     } catch (e) {
//       log('❌ Erreur handlePinTimeoutNavigation: $e');
//       _redirectToLogin();
//     }
//   }

//   // Ajoutez cette méthode pour déboguer les transitions
//   void _navigateBasedOnStatus(AuthStatusModel status) {
//     if (_context == null || !_context!.mounted) {
//       log('⚠️ Context non valide pour navigation');
//       return;
//     }

//     log('📍 === NAVIGATION DEBUG ===');
//     log('📍 Has Pin Code: ${status.hasPinCode}');
//     log('📍 Is Authenticated: ${status.isAuthenticated}');
//     log('📍 Is First Time: ${status.isFirstTime}');
//     log('📍 Required Pin Auth: ${status.requiredPinAuth}');
//     log('📍 ======================');

//     if (!status.isAuthenticated) {
//       log('❌ Non authentifié → Login');
//       navigateWithTransition(
//         context: _context!,
//         page: LoginView(),
//         direction: TransitionDirection.rightToLeft,
//         replace: true,
//       );
//     } else if (!status.hasPinCode) {
//       log('🔧 Pas de PIN configuré → Création PIN');
//       navigateWithTransition(
//         context: _context!,
//         page: const CreatePinView(),
//         direction: TransitionDirection.rightToLeft,
//         replace: true,
//       );
//     } else if (status.requiredPinAuth) {
//       log('🔒 PIN requis → Vérification PIN');
//       navigateWithTransition(
//         context: _context!,
//         page: const VerifyPinView(),
//         direction: TransitionDirection.rightToLeft,
//         replace: true,
//       );
//     } else {
//       log('✅ Accès autorisé → Accueil');
//       navigateWithTransition(
//         context: _context!,
//         page: const MainView(),
//         direction: TransitionDirection.rightToLeft,
//         replace: true,
//       );
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

//   // ⭐ Nouvelle méthode pour gérer le timeout PIN avec la même logique que SplashView
//   //

//   void _redirectToLogin() {
//     try {
//       if (_context != null && _context!.mounted) {
//         log('🔄 Redirection login avec context');
//         navigateWithTransition(
//           context: _context!,
//           page: LoginView(),
//           direction: TransitionDirection.rightToLeft,
//           replace: true,
//         );
//       } else {
//         // Fallback vers NavigationService si pas de context
//         log('🔄 Redirection login avec NavigationService (fallback)');
//         NavigationService.navigateToLogin();
//       }
//     } catch (e) {
//       log('❌ Erreur redirection login: $e');
//       // Dernier recours avec NavigationService
//       try {
//         NavigationService.navigateToLogin();
//       } catch (fallbackError) {
//         log('❌ Erreur fallback navigation: $fallbackError');
//       }
//     }
//   }

//   // Méthode utilitaire pour débugger l'état du handler
//   void debugStatus() {
//     log('=== LIFECYCLE HANDLER DEBUG ===');
//     log('Context disponible: ${_context != null}');
//     log('Context mounted: ${_context?.mounted ?? false}');
//     log('Is refreshing: $_isRefreshing');
//     log('Last pause time: $_lastPauseTime');
//     log('Pin timeout minutes: $pinTimeoutMinutes');
//     log('==============================');
//   }
// }

class LifecycleHandler extends WidgetsBindingObserver {
  // Singleton pattern
  static LifecycleHandler? _instance;

  static bool isInRegistrationFlow = false;
  static bool isInLoginFlow = false;

  WebSocketService wsService = WebSocketService();

  LifecycleHandler._internal();

  static LifecycleHandler get instance {
    _instance ??= LifecycleHandler._internal();
    return _instance!;
  }

  bool _isRefreshing = false;
  DateTime? _lastPauseTime;
  static const int pinTimeoutMinutes = 1;
  BuildContext? _context;

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
        // ⭐ NE PAS déconnecter le WebSocket sur inactive
        // C'est un état transitoire quand on switch d'app
        break;

      case AppLifecycleState.detached:
        log('[LIFECYCLE] App detached');
        // Déconnexion définitive
        await wsService.disconnect();
        break;

      case AppLifecycleState.hidden:
        log('[LIFECYCLE] App hidden');
        // ⭐ Marquer le temps de pause seulement si pas déjà fait
        if (_lastPauseTime == null) {
          _lastPauseTime = DateTime.now();
        }
        // ⭐ Déconnecter le WebSocket sur hidden (pause réelle)
        await wsService.disconnect();
        break;
    }
  }

  Future<void> _handleAppResume(AuthService authService) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      log('🔍 === RESUME APP - VÉRIFICATION STATUT ===');

      // Vérification des tokens en premier
      String? token = await authService.getAccessToken();
      final refreshToken = await authService.getRefreshToken();

      if (token == null || refreshToken == null) {
        log('❌ Pas de tokens - redirection login');
        await authService.clearTokens();
        _redirectToLogin();
        return;
      }

      // Vérifier si l'access token est expiré
      if (authService.isTokenExpired(token)) {
        log('⚠️ Access token expiré - tentative de refresh');
        if (authService.isTokenExpired(refreshToken)) {
          log('🔴 Refresh token aussi expiré - déconnexion');
          await authService.clearTokens();
          _redirectToLogin();
          return;
        }

        final refreshSuccess = await authService.refreshAuthToken();
        if (!refreshSuccess) {
          log('🔴 Échec du refresh - déconnexion');
          await authService.clearTokens();
          _redirectToLogin();
          return;
        }

        // ⭐ Récupérer le nouveau token après refresh
        final newToken = await authService.getAccessToken();
        if (newToken != null) {
          token = newToken;
        }
      }

      // ⭐ Gestion intelligente de la reconnexion WebSocket
      await _handleWebSocketReconnection(token, authService);

      // MAINTENANT vérifier si on doit demander le PIN
      if (_lastPauseTime != null) {
        final timeDiff = DateTime.now().difference(_lastPauseTime!);
        log('⏱️ Temps hors app: ${timeDiff.inMinutes} minutes');

        if (timeDiff.inMinutes >= pinTimeoutMinutes) {
          log('🔒 Temps dépassé - Vérification statut pour PIN');
          await _handlePinTimeoutNavigation(authService);
          return;
        } else {
          log('✅ Temps OK - pas besoin de PIN');
        }
      }

      log('✅ Reprise normale de l\'app');
    } catch (e) {
      log('❌ Erreur handleAppResume: $e');
      // ⭐ En cas d'erreur, essayer quand même de reconnecter le WebSocket
      try {
        final token = await authService.getAccessToken();
        if (token != null) {
          await _handleWebSocketReconnection(token, authService);
        }
      } catch (wsError) {
        log('❌ Erreur reconnexion WebSocket de secours: $wsError');
      }
    } finally {
      _isRefreshing = false;
      _lastPauseTime = null;
    }
  }

  // ⭐ Méthode améliorée pour gérer la reconnexion WebSocket de façon robuste
  Future<void> _handleWebSocketReconnection(
    String token,
    AuthService authService,
  ) async {
    try {
      log('🔄 Début reconnexion WebSocket...');

      // ⭐ FORCER une déconnexion complète d'abord
      await wsService.disconnect();
      await Future.delayed(Duration(milliseconds: 1000));

      // ⭐ Reset complet de l'état WebSocket
      wsService.resetState();

      // ⭐ Vérifier la connectivité réseau avant de tenter la reconnexion
      try {
        // Test simple de connectivité
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(Duration(seconds: 5));
        if (result.isEmpty) {
          log('🌐 Pas de connectivité internet détectée');
          _scheduleDelayedReconnection(token);
          return;
        }
      } catch (e) {
        log('🌐 Erreur test connectivité: $e - tentative quand même...');
      }

      // Vérifier l'état du WebSocket
      if (!wsService.isHealthy()) {
        log('⚠️ WebSocket non sain - reconnexion nécessaire...');

        // Reconnecter avec retry automatique et timeout plus court
        final success = await wsService.reconnectWithRetry(
          token,
          maxRetries: 3,
        );
        if (success) {
          await Future.delayed(Duration(milliseconds: 2000));
          wsService.safeRequestWalletUpdate();
          log('✅ WebSocket reconnecté avec succès');
        } else {
          log(
            '❌ Impossible de reconnecter le WebSocket après plusieurs tentatives',
          );
          _scheduleDelayedReconnection(token);
        }
      } else {
        log('✅ WebSocket déjà sain - mise à jour wallet');
        wsService.safeRequestWalletUpdate();
      }
    } catch (e) {
      log('❌ Erreur lors de la reconnexion WebSocket: $e');
      _scheduleDelayedReconnection(token);
    }
  }

  // ⭐ Nouvelle méthode pour programmer une reconnexion différée
  void _scheduleDelayedReconnection(String token) {
    Timer(Duration(seconds: 5), () async {
      try {
        log('🔄 Tentative de reconnexion différée...');
        await wsService.disconnect();
        await Future.delayed(Duration(milliseconds: 500));
        wsService.resetState();

        final success = await wsService.reconnectWithRetry(
          token,
          maxRetries: 3,
        );
        if (success) {
          await Future.delayed(Duration(milliseconds: 1000));
          wsService.safeRequestWalletUpdate();
          log('✅ Reconnexion différée réussie');
        } else {
          log('❌ Échec de la reconnexion différée');
        }
      } catch (e) {
        log('❌ Erreur reconnexion différée: $e');
      }
    });
  }

  Future<void> _handlePinTimeoutNavigation(AuthService authService) async {
    try {
      log('🔒 Gestion timeout PIN - vérification statut auth');

      final authStatus = await authService.checkAuthStatus(forceRefresh: true);
      log('📊 Statut auth reçu: ${authStatus.toString()}');

      if (_context != null && _context!.mounted) {
        _navigateBasedOnStatus(authStatus);
      } else {
        log('⚠️ Context non disponible pour navigation PIN');
        _redirectToLogin();
      }
    } catch (e) {
      log('❌ Erreur handlePinTimeoutNavigation: $e');
      _redirectToLogin();
    }
  }

  void _navigateBasedOnStatus(AuthStatusModel status) {
    if (_context == null || !_context!.mounted) {
      log('⚠️ Context non valide pour navigation');
      return;
    }

    log('📍 === NAVIGATION DEBUG ===');
    log('📍 Has Pin Code: ${status.hasPinCode}');
    log('📍 Is Authenticated: ${status.isAuthenticated}');
    log('📍 Is First Time: ${status.isFirstTime}');
    log('📍 Required Pin Auth: ${status.requiredPinAuth}');
    log('📍 ======================');

    if (!status.isAuthenticated) {
      log('❌ Non authentifié → Login');
      navigateWithTransition(
        context: _context!,
        page: LoginView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else if (!status.hasPinCode) {
      log('🔧 Pas de PIN configuré → Création PIN');
      navigateWithTransition(
        context: _context!,
        page: const CreatePinView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else if (status.requiredPinAuth) {
      log('🔒 PIN requis → Vérification PIN');
      navigateWithTransition(
        context: _context!,
        page: const VerifyPinView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else {
      log('✅ Accès autorisé → Accueil');
      navigateWithTransition(
        context: _context!,
        page: const MainView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    }
  }

  Future<void> _handleAppPause(AuthService authService) async {
    try {
      log('⏸️ App mise en pause - sauvegarde état');

      // ⭐ Déconnecter le WebSocket immédiatement
      await wsService.disconnect();

      // Mettre à jour le background time
      final token = await authService.getAccessToken();
      if (token != null && !authService.isTokenExpired(token)) {
        try {
          final apiService = ApiService();
          await apiService.updateBackgroundTime(token: token);
          log('✅ Background time updated');
        } catch (e) {
          log('⚠️ Erreur update background time: $e (non critique)');
        }
      } else {
        log('⚠️ Token invalide - pas de update background time');
      }
    } catch (e) {
      log('❌ Erreur handleAppPause: $e');
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
        log('🔄 Redirection login avec NavigationService (fallback)');
        NavigationService.navigateToLogin();
      }
    } catch (e) {
      log('❌ Erreur redirection login: $e');
      try {
        NavigationService.navigateToLogin();
      } catch (fallbackError) {
        log('❌ Erreur fallback navigation: $fallbackError');
      }
    }
  }

  void debugStatus() {
    log('=== LIFECYCLE HANDLER DEBUG ===');
    log('Context disponible: ${_context != null}');
    log('Context mounted: ${_context?.mounted ?? false}');
    log('Is refreshing: $_isRefreshing');
    log('Last pause time: $_lastPauseTime');
    log('Pin timeout minutes: $pinTimeoutMinutes');
    log('WebSocket healthy: ${wsService.isHealthy()}');
    log('==============================');
  }
}
