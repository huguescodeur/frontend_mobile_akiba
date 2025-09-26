import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildTransactionItem(
  String title,
  String amount,
  String date,
  IconData icon,
  Color color,
) {
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  color: AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: amount.startsWith('+') ? AppColors.success : AppColors.error,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
