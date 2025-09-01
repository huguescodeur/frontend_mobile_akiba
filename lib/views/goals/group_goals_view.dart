import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GroupGoalsView extends StatelessWidget {
  const GroupGoalsView({super.key});
  static const String idView = "groupgoalview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objectifs Collectifs'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Objectifs et challenges de groupe',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
