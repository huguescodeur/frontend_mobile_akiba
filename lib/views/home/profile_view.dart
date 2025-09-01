import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/viewmodels/user_view_model/user_provider.dart';
import 'package:akiba/views/epargne/reports_view.dart';
import 'package:akiba/views/notifications/notification_settings_view.dart';
import 'package:akiba/views/profile/edit_profile_view.dart';
import 'package:akiba/views/settings/about_view.dart';
import 'package:akiba/views/settings/security_view.dart';
import 'package:akiba/views/settings/settings_view.dart';
import 'package:akiba/views/transactions/transactions_view.dart';
import 'package:akiba/views/vault/vault_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  static const String idView = "profileview";

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    String formatDate(DateTime date) {
      return DateFormat('dd MMMM, yyyy').format(date);
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Header profil
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, Color(0xFF0066FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:
                          currentUser?.hasProfilePicture == true
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  currentUser!.profilePicture!,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Center(
                                child: Text(
                                  currentUser?.initials ?? 'U',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      currentUser?.fullName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      // 'Membre depuis Mars 2024',
                      currentUser != null
                          ? 'Membre depuis ${formatDate(currentUser.dateJoined)}'
                          : '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProfileStat('Challenges', '12', Iconsax.cup),
                        _buildProfileStat('Objectifs', '8', Iconsax.activity),
                        _buildProfileStat('Niveau', '🥇', null),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Menu options
              _buildMenuSection('Compte', [
                _buildMenuItem(
                  'Modifier profil',
                  Iconsax.edit,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfileView()),
                  ),
                ),
                _buildMenuItem(
                  'Sécurité & Confidentialité',
                  Iconsax.security,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SecurityView()),
                  ),
                ),
                _buildMenuItem(
                  'Notifications',
                  Iconsax.notification,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationSettingsView(),
                    ),
                  ),
                ),
              ]),

              SizedBox(height: 16),

              _buildMenuSection('Épargne', [
                _buildMenuItem(
                  'Historique complet',
                  Iconsax.document,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TransactionsView()),
                  ),
                ),
                _buildMenuItem(
                  'Mes coffres-forts',
                  Iconsax.safe_home,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VaultView()),
                  ),
                ),
                _buildMenuItem(
                  'Rapports d\'épargne',
                  Iconsax.chart_1,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReportsView()),
                  ),
                ),
              ]),

              SizedBox(height: 16),

              _buildMenuSection('Support', [
                _buildMenuItem('Centre d\'aide', Iconsax.info_circle, () {}),
                _buildMenuItem('Nous contacter', Iconsax.message, () {}),
                _buildMenuItem(
                  'Signaler un problème',
                  Iconsax.warning_2,
                  () {},
                ),
              ]),

              SizedBox(height: 16),

              _buildMenuSection('Application', [
                _buildMenuItem(
                  'Paramètres',
                  Iconsax.setting,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsView()),
                  ),
                ),
                _buildMenuItem(
                  'À propos',
                  Iconsax.info_circle,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutView()),
                  ),
                ),
                _buildMenuItem(
                  'Se déconnecter',
                  Iconsax.logout,
                  () => _showLogoutDialog(context),
                  isDestructive: true,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData? icon) {
    return Column(
      children: [
        if (icon != null)
          Icon(icon, color: Colors.white, size: 24)
        else
          Text(value, style: TextStyle(fontSize: 24)),
        if (icon != null) SizedBox(height: 4),
        if (icon != null)
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
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
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textLight,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        color: AppColors.textSecondaryLight,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Se déconnecter'),
            content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Se déconnecter',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
