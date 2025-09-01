import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class CreateGroupView extends StatelessWidget {
  const CreateGroupView({super.key});
  static const String idView = "creategroupview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un Groupe'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Formulaire de création de groupe',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
