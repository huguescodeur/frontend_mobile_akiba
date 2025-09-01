import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TransferView extends StatelessWidget {
  const TransferView({super.key});

  static const String idView = "transferview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transférer'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
      ),
      body: Center(
        child: Text('Interface de transfert', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
