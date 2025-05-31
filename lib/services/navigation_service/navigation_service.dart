import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void navigateToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      LoginView.idView,
      (route) => false,
    );
  }

  static void navigateToPin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      VerifyPinView.idView,
      (route) => false,
    );
  }
}
