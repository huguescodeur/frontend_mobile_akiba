import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ChallengeDetailsView extends StatelessWidget {
  const ChallengeDetailsView({super.key});

  static const String idView = "challengedetailsview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails Challenge'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Détails du challenge avec classement',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
