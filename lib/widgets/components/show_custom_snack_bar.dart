import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

void showCustomSnackBar(
  BuildContext context, {
  bool isError = false,
  required String message,
}) {
  final bgColor = isError ? AppColors.error : AppColors.success;
  final icon = isError ? Icons.error : Icons.check_circle;

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const Gap(12),
          Expanded(
            child: Text(
              // textAlign: TextAlign.center,
              message,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}

// void showCustomSnackBar(
//   BuildContext context, {
//   bool isError = false,
//   required String message,
// }) {
//   final bgColor = isError ? AppColors.error : AppColors.success;
//   final icon = isError ? Icons.error : Icons.check_circle;

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       backgroundColor: bgColor,
//       content: Row(
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(message, style: const TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       duration: const Duration(seconds: 4),
//     ),
//   );
// }
