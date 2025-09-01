import 'package:akiba/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

Widget buildBottomNavigation({
  required Function(int) onTap,
  required int currentIndex,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.textSecondaryLight,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home),
          activeIcon: Icon(Iconsax.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.chart_1),
          activeIcon: Icon(Iconsax.chart_1),
          label: 'Statistiques',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.people),
          activeIcon: Icon(Iconsax.people),
          label: 'Communauté',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.activity),
          activeIcon: Icon(Iconsax.activity),
          label: 'Objectifs',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.profile_circle),
          activeIcon: Icon(Iconsax.profile_circle),
          label: 'Profil',
        ),
      ],
    ),
  );
}
