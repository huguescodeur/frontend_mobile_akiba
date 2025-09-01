import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CreateGoalsView extends StatelessWidget {
  const CreateGoalsView({super.key});
  static const String idView = "creategoalview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvel Objectif'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Formulaire de création d\'objectif',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
