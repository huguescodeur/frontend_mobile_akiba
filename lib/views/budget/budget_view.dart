import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BudgetView extends StatelessWidget {
  const BudgetView({super.key});
  static const String idView = "budgetview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget & Dépenses'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Suivi du budget et catégorisation des dépenses',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
