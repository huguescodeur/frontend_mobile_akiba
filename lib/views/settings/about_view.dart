import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});
  static const String idView = "aboutview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('À propos'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Informations sur l\'application Akiba',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
