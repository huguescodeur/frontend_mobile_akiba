import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});
  static const String idView = "editprofileview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Formulaire d\'édition du profil',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
