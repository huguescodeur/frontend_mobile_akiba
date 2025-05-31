import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/constants/routes.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/services/navigation_service/navigation_service.dart';
import 'package:akiba/utils/lifecycle_handler.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/auth/register/register_view.dart';
import 'package:akiba/views/home/onboarding_view.dart';
import 'package:akiba/views/home/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Utiliser le singleton du LifecycleHandler
  WidgetsBinding.instance.addObserver(LifecycleHandler.instance);

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AuthService authService = AuthService();
    authService.tokenExist();

    // Définir le context pour le lifecycle handler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (NavigationService.navigatorKey.currentContext != null) {
        LifecycleHandler.instance.setContext(
          NavigationService.navigatorKey.currentContext!,
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundLight,
          appBarTheme: AppBarTheme(backgroundColor: AppColors.backgroundLight),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routes: routes,
        initialRoute: SplashView.idView,
        // Observer pour maintenir le context à jour
        navigatorObservers: [_AppNavigatorObserver()],
      ),
    );
  }
}

// Observer simple pour maintenir le context à jour
class _AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateLifecycleContext();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _updateLifecycleContext();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateLifecycleContext();
  }

  void _updateLifecycleContext() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (NavigationService.navigatorKey.currentContext != null) {
        LifecycleHandler.instance.setContext(
          NavigationService.navigatorKey.currentContext!,
        );
      }
    });
  }
}

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   WidgetsBinding.instance.addObserver(LifecycleHandler());
//   runApp(ProviderScope(child: MyApp()));
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     AuthService authService = AuthService();
//     authService.tokenExist();
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         systemNavigationBarColor: Colors.black,
//       ),
//       child: MaterialApp(
//         navigatorKey: NavigationService.navigatorKey,
//         debugShowCheckedModeBanner: false,
//         title: 'Flutter Demo',
//         theme: ThemeData(
//           scaffoldBackgroundColor: AppColors.backgroundLight,
//           appBarTheme: AppBarTheme(backgroundColor: AppColors.backgroundLight),
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         ),
//         routes: routes,
//         initialRoute: SplashView.idView,
//         // initialRoute: RegisterView.idView,
//       ),
//     );
//   }
// }
