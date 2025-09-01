import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  static const String idView = "transactionsview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Toutes les transactions'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Historique complet des transactions',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
