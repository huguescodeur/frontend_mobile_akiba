import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PublicChallengesView extends StatelessWidget {
  const PublicChallengesView({super.key});
  static const String idView = "publicchallengesview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges Publics'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Liste des challenges publics à rejoindre',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
