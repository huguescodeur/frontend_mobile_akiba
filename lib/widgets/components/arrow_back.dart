import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';

GestureDetector arrowBack({required Function() onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      margin: EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Iconsax.arrow_left,
        color: AppColors.primaryLight,
        size: 25,
      ),
    ),
  );
}
