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
import 'package:akiba/views/home/main_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';

import 'package:akiba/models/auth_status_model.dart';

class LifecycleHandler extends WidgetsBindingObserver {
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
  Timer? _resumeTimer;

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
        // État transitoire - ne rien faire de drastique
        break;

      case AppLifecycleState.detached:
        log('[LIFECYCLE] App detached');
        await wsService.disconnect();
        break;

      case AppLifecycleState.hidden:
        log('[LIFECYCLE] App hidden');
        if (_lastPauseTime == null) {
          _lastPauseTime = DateTime.now();
        }
        // Notifier le WebSocket que l'app est en background
        wsService.onAppPaused();
        break;
    }
  }

  Future<void> _handleAppResume(AuthService authService) async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      log('🔍 === RESUME APP - VÉRIFICATION STATUT ===');

      // Notifier le WebSocket que l'app est revenue
      wsService.onAppResumed();

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

        final newToken = await authService.getAccessToken();
        if (newToken != null) {
          token = newToken;
        }
      }

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
      // En cas d'erreur, essayer de maintenir la session
      try {
        final token = await authService.getAccessToken();
        if (token != null) {
          log('🔄 Tentative de reconnexion WebSocket de secours...');
          wsService.onAppResumed(); // Cela va déclencher la reconnexion
        }
      } catch (wsError) {
        log('❌ Erreur reconnexion WebSocket de secours: $wsError');
      }
    } finally {
      _isRefreshing = false;
      _lastPauseTime = null;
    }
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
      log('⏸️ App mise en pause');

      // Notifier le WebSocket Service
      wsService.onAppPaused();

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

  void dispose() {
    _resumeTimer?.cancel();
    wsService.dispose();
  }
}
