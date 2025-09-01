import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PersonalGoalsView extends StatelessWidget {
  const PersonalGoalsView({super.key});
  static const String idView = "personalgoalview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objectifs Personnels'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Challenges et objectifs privés',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
