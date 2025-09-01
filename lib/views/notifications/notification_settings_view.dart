import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});
  static const String idView = "notificationsettingsview";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text(
          'Paramètres des notifications',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
