import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildStatsSection(String title, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      ...children.map(
        (child) => Padding(padding: EdgeInsets.only(bottom: 12), child: child),
      ),
    ],
  );
}
