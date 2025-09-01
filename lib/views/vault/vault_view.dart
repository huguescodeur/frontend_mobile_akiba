import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class VaultView extends StatelessWidget {
  const VaultView({super.key});
  static const String idView = "vaultview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffres-forts'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Gestion des coffres-forts temporaires',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
