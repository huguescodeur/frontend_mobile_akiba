import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SolifondsView extends StatelessWidget {
  const SolifondsView({super.key});
  static const String idView = "solifondsview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tontines & Cagnottes'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Gestion des tontines et cagnottes collectives',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
