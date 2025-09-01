import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CreateChallengeView extends StatelessWidget {
  const CreateChallengeView({super.key});
  static const String idView = "createchallengeview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Challenge'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Formulaire de création de challenge',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
