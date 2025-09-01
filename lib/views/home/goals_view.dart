import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/views/budget/budget_view.dart';
import 'package:akiba/views/goals/create_goals_view.dart';
import 'package:akiba/views/goals/group_goals_view.dart';
import 'package:akiba/views/goals/personal_goals_view.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class GoalsView extends StatelessWidget {
  const GoalsView({super.key});

  static const String idView = "goalsview";

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
                'Mes Objectifs',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),

              // Types d'objectifs
              Row(
                children: [
                  Expanded(
                    child: _buildGoalTypeCard(
                      'Personnel',
                      Iconsax.user,
                      AppColors.primaryLight,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PersonalGoalsView()),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildGoalTypeCard(
                      'Collectif',
                      Iconsax.people,
                      AppColors.success,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GroupGoalsView()),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildGoalTypeCard(
                      'Budget',
                      Iconsax.chart_1,
                      AppColors.accentLight,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BudgetView()),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Objectifs actifs
              _buildSection('Objectifs Actifs', [
                _buildGoalItem(
                  'Voyage en Europe',
                  '750 000 CFA',
                  0.45,
                  '340 000 CFA épargné',
                  AppColors.primaryLight,
                  '2 mois restants',
                ),
                _buildGoalItem(
                  'Nouveau téléphone',
                  '200 000 CFA',
                  0.80,
                  '160 000 CFA épargné',
                  AppColors.success,
                  '3 semaines restantes',
                ),
                _buildGoalItem(
                  'Formation en ligne',
                  '50 000 CFA',
                  0.30,
                  '15 000 CFA épargné',
                  AppColors.accentLight,
                  '1 mois restant',
                ),
              ]),

              SizedBox(height: 24),

              // Challenges personnels
              _buildSection('Challenges Personnels', [
                _buildPersonalChallengeItem(
                  'Épargner tous les jours',
                  'Jour 12/30',
                  0.40,
                  AppColors.primaryLight,
                ),
                _buildPersonalChallengeItem(
                  'Pas de dépenses inutiles',
                  'Jour 5/7',
                  0.71,
                  AppColors.success,
                ),
                _buildPersonalChallengeItem(
                  '50 000 CFA ce mois',
                  '32 500 / 50 000',
                  0.65,
                  AppColors.accentLight,
                ),
              ]),

              SizedBox(height: 24),

              // Objectifs terminés
              _buildSection('Récemment Terminés', [
                _buildCompletedGoalItem(
                  'Ordinateur portable',
                  '500 000 CFA',
                  '✅ Réussi le 20 Dec',
                ),
                _buildCompletedGoalItem(
                  'Épargne urgence',
                  '100 000 CFA',
                  '✅ Réussi le 15 Dec',
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
              MaterialPageRoute(builder: (_) => CreateGoalsView()),
            ),
        backgroundColor: AppColors.primaryLight,
        child: Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGoalTypeCard(
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

  Widget _buildGoalItem(
    String title,
    String target,
    double progress,
    String saved,
    Color color,
    String timeLeft,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                timeLeft,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Objectif: $target',
            style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
          ),
          Text(
            saved,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
          SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% complété',
            style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalChallengeItem(
    String title,
    String progress,
    double value,
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
            child: Icon(Iconsax.activity, color: color, size: 20),
          ),
          SizedBox(width: 16),
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
                  progress,
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppColors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedGoalItem(String title, String amount, String status) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
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
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.tick_circle,
              color: AppColors.success,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
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
                  amount,
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
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
