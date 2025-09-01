import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  static const String idView = "settingsview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Paramètres de l\'application',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
