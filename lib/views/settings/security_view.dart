import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});
  static const String idView = "securityview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sécurité'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Paramètres de sécurité et confidentialité',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
