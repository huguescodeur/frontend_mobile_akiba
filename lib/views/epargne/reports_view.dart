import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});
  static const String idView = "reportsview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapports'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Rapports détaillés d\'épargne',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
