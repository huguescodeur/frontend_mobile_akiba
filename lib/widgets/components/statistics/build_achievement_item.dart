import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildAchievementItem(
  String title,
  String value,
  String percentage,
  Color color,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
      ),
      SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8),
      TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 1500),
        tween: Tween(
          begin: 0.0,
          end: double.parse(percentage.replaceAll('%', '')) / 100,
        ),
        builder: (context, animValue, child) {
          return LinearProgressIndicator(
            value: animValue,
            backgroundColor: AppColors.backgroundLightGray,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          );
        },
      ),
      SizedBox(height: 4),
      Text(
        percentage,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
