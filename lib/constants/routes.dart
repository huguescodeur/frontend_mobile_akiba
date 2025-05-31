import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/auth/register/create_pin_view.dart';
import 'package:akiba/views/auth/register/register_view.dart';
import 'package:akiba/views/auth/register/verify_number_view.dart';
import 'package:akiba/views/home/accueil_view.dart';
import 'package:akiba/views/home/onboarding_view.dart';
import 'package:akiba/views/home/splash_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> routes = {
  SplashView.idView: (context) => const SplashView(),
  OnboardingView.idView: (context) => OnboardingView(),
  LoginView.idView: (context) => LoginView(),
  RegisterView.idView: (context) => RegisterView(),
  VerifyNumberView.idView: (context) => VerifyNumberView(),
  CreatePinView.idView: (context) => CreatePinView(),
  AccueilView.idView: (context) => AccueilView(),
  VerifyPinView.idView: (context) => VerifyPinView(),
};
