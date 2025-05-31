import 'dart:developer';

import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccueilView extends ConsumerStatefulWidget {
  const AccueilView({super.key});

  static const String idView = "accueilview";

  @override
  ConsumerState<AccueilView> createState() => _AccueilViewState();
}

class _AccueilViewState extends ConsumerState<AccueilView> {
  final AuthService authService = AuthService();

  token() async {
    final token = await AuthService().getAccessToken();
    authService.checkTokenExpiry(token!);

    log("My Tokennnn: $token");

    return token;
  }

  tokenRefresh() async {
    final token = await AuthService().getRefreshToken();
    authService.checkTokenExpiry(token!);

    log("My Tokennnn Refreshhhhhh: $token");

    return token;
  }

  @override
  Widget build(BuildContext context) {
    token();
    tokenRefresh();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("Acceuil")],
            ),
          ),
        ),
      ),
    );
  }
}
