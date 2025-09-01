import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/widgets/components/statistics/build_achievement_item.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

Widget buildAchievementsSection({required Map<String, dynamic> currentData}) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.award, color: AppColors.accentLight, size: 24),
            SizedBox(width: 8),
            Text(
              'Accomplissements',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildAchievementItem(
                'Challenges réussis',
                '${currentData['achievements']['completed']}/${currentData['achievements']['total']}',
                '${((currentData['achievements']['completed'] / currentData['achievements']['total']) * 100).toInt()}%',
                AppColors.success,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: buildAchievementItem(
                'Objectifs atteints',
                '${currentData['goals']['completed']}/${currentData['goals']['total']}',
                '${((currentData['goals']['completed'] / currentData['goals']['total']) * 100).toInt()}%',
                AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
