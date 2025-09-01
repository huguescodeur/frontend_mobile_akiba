import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WithdrawView extends StatelessWidget {
  const WithdrawView({super.key});

  static const String idView = "withdrawview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Effectuer un retrait'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text('Interface de retrait', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
