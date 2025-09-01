import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class DepositView extends StatelessWidget {
  const DepositView({super.key});

  static const String idView = "depositview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faire un dépôt'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text('Interface de dépôt', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
