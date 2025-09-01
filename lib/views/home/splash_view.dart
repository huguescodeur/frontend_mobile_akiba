// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/models/auth_status_model.dart';
import 'package:akiba/models/auth_tokens_model.dart';
import 'package:akiba/services/api_service.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/utils/app_utils.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/auth/register/create_pin_view.dart';
import 'package:akiba/views/home/accueil_view.dart';
import 'package:akiba/views/home/home_view.dart';
import 'package:akiba/views/home/main_view.dart';
import 'package:akiba/views/home/onboarding_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget with WidgetsBindingObserver {
  static const String idView = 'splashview';

  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _handleNavigation();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation() async {
    // Attendre minimum pour l'animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // final authStatus = await _checkAuthStatus();
      final authStatus = await authService.checkAuthStatus();

      if (mounted) {
        _navigateBasedOnStatus(authStatus);
      }
    } catch (e) {
      log('❌ Erreur check auth status: $e');
      if (mounted) {
        // En cas d'erreur, aller vers onboarding par sécurité
        _navigateToOnboarding();
      }
    }
  }

  void _navigateBasedOnStatus(AuthStatusModel status) {
    log('📍 Navigation basée sur le statut: $status');
    log('📍 Has Pin Code: ${status.hasPinCode}');
    log('📍 Is Auth: ${status.isAuthenticated}');
    log('📍 Is First Time: ${status.isFirstTime}');
    log('📍 Required Pin Auth: ${status.requiredPinAuth}');

    if (status.isAuthenticated &&
        status.hasPinCode &&
        !status.requiredPinAuth) {
      navigateWithTransition(
        context: context,
        // page: const HomeView(),
        page: const MainView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else if (status.isAuthenticated &&
        status.hasPinCode &&
        status.requiredPinAuth) {
      navigateWithTransition(
        context: context,
        page: const VerifyPinView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else if (status.isAuthenticated && !status.hasPinCode) {
      navigateWithTransition(
        context: context,
        page: const CreatePinView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    } else if (status.isFirstTime) {
      _navigateToOnboarding();
    } else {
      navigateWithTransition(
        context: context,
        page: LoginView(),
        direction: TransitionDirection.rightToLeft,
        replace: true,
      );
    }
  }

  void _navigateToOnboarding() async {
    await AppUtils.markFirstTimeComplete();

    navigateWithTransition(
      context: context,
      page: const OnboardingView(),
      replace: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primaryLight,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryLight,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryLight,
                    AppColors.primaryLight.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo principal
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 60,
                            color: AppColors.primaryLight,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Nom de l'app
                        const Text(
                          'Sanek',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Slogan
                        Text(
                          'Gérez . Défiez . Réussissez ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Indicateur de chargement
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Chargement...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
