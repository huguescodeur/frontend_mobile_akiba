// main_view.dart - Vue principale avec navigation
import 'package:akiba/viewmodels/user_view_model/user_provider.dart';
import 'package:akiba/views/home/accueil_view.dart';
import 'package:akiba/views/home/community_view.dart';
import 'package:akiba/views/home/goals_view.dart';
import 'package:akiba/views/home/home_view.dart';
import 'package:akiba/views/home/profile_view.dart';
import 'package:akiba/views/home/statistics_view.dart';
import 'package:akiba/views/home/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:akiba/constants/app_colors.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  static const String idView = "mainview";

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // const HomeView(),
    const AccueilView(),
    const StatisticsView(),
    const CommunityView(),
    const GoalsView(),
    // const WalletTestScreen(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    final currentUser = ref.watch(currentUserProvider);
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
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryLight,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.chart_1),

            label: 'Statistiques',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.people),
            label: 'Communauté',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.activity),
            label: 'Objectifs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle),
            // icon: Container(
            //   height: 30,
            //   width: 30,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     borderRadius: BorderRadius.circular(50),
            //   ),
            //   child:
            //       currentUser?.hasProfilePicture == true
            //           ? ClipRRect(
            //             borderRadius: BorderRadius.circular(50),
            //             child: Image.network(
            //               currentUser!.profilePicture!,
            //               fit: BoxFit.cover,
            //             ),
            //           )
            //           : Center(
            //             child: Text(
            //               currentUser?.initials ?? 'U',
            //               style: TextStyle(
            //                 color: Colors.grey[600],
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ),
            // ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
