import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/views/challenge/create_challenge_view.dart';
import 'package:akiba/views/challenge/public_challenges_view.dart';
import 'package:akiba/views/community/create_group_view.dart';
import 'package:akiba/views/solifonds/solifonds_view.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  static const String idView = "communityview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Communauté',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),

              // Actions communauté
              Row(
                children: [
                  Expanded(
                    child: _buildCommunityAction(
                      'Challenges\nPublics',
                      Iconsax.people,
                      AppColors.primaryLight,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicChallengesView(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildCommunityAction(
                      'Créer\nGroupe',
                      Iconsax.add_circle,
                      AppColors.success,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateGroupView()),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildCommunityAction(
                      'Tontines',
                      Iconsax.dollar_circle,
                      AppColors.accentLight,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SolifondsView()),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Mes groupes
              _buildSection('Mes Groupes', [
                _buildGroupItem(
                  'Famille Goli',
                  '12 membres',
                  '🏠',
                  AppColors.primaryLight,
                ),
                _buildGroupItem(
                  'Collègues Bureau',
                  '8 membres',
                  '💼',
                  AppColors.success,
                ),
                _buildGroupItem(
                  'Amis Université',
                  '15 membres',
                  '🎓',
                  AppColors.accentLight,
                ),
              ]),

              SizedBox(height: 24),

              // Challenges populaires
              _buildSection('Challenges Populaires', [
                _buildChallengeItem(
                  'Défi 30 jours',
                  '245 participants',
                  '30 000 CFA',
                  '🏆',
                ),
                _buildChallengeItem(
                  'Épargne Semaine',
                  '128 participants',
                  '5 000 CFA',
                  '⭐',
                ),
                _buildChallengeItem(
                  'Challenge Mensuel',
                  '89 participants',
                  '50 000 CFA',
                  '🎯',
                ),
              ]),

              SizedBox(height: 24),

              // Tontines actives
              _buildSection('Tontines Actives', [
                _buildTontineItem(
                  'Tontine Mensuelle',
                  '12/12 membres',
                  'Rotation : 15 Jan',
                  AppColors.success,
                ),
                _buildTontineItem(
                  'Épargne Collective',
                  '8/10 membres',
                  'Cotisation : 25 000 CFA',
                  AppColors.primaryLight,
                ),
              ]),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CreateChallengeView()),
            ),
        backgroundColor: AppColors.primaryLight,
        child: Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCommunityAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildGroupItem(
    String name,
    String members,
    String emoji,
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
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 24)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  members,
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Iconsax.arrow_right_3,
            color: AppColors.textSecondaryLight,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(
    String name,
    String participants,
    String amount,
    String emoji,
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
          Text(emoji, style: TextStyle(fontSize: 32)),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  participants,
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Objectif: $amount',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Rejoindre', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTontineItem(
    String name,
    String status,
    String info,
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
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                Text(
                  info,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
