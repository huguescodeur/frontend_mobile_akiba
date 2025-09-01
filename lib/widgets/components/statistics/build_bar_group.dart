import 'package:akiba/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

BarChartGroupData buildBarGroup(int x, double y) {
  return BarChartGroupData(
    x: x,
    barRods: [
      BarChartRodData(
        toY: y,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.primaryLight,
            AppColors.primaryLight.withOpacity(0.7),
          ],
        ),
        width: 20,
        borderRadius: BorderRadius.circular(4),
      ),
    ],
  );
}
