import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/models/auth_models/user_model.dart';
import 'package:akiba/models/wallet_models/transaction_model.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/viewmodels/user_view_model/user_provider.dart';
import 'package:akiba/viewmodels/wallet_view_model/wallet_provider.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/challenge/challenge_details_view.dart';
import 'package:akiba/views/notifications/notifications_view.dart';
import 'package:akiba/views/settings/settings_view.dart';
import 'package:akiba/views/transactions/deposit_view.dart';
import 'package:akiba/views/transactions/transaction_detail_view.dart';
import 'package:akiba/views/transactions/transactions_view.dart';
import 'package:akiba/views/vault/vault_view.dart';
import 'package:akiba/widgets/components/accueil_components/build_quick_actions.dart';
import 'package:akiba/widgets/components/build_transaction_item.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class AccueilView extends ConsumerStatefulWidget {
  const AccueilView({super.key});

  static const String idView = "accueilview";

  @override
  ConsumerState<AccueilView> createState() => _AccueilViewState();
}

class _AccueilViewState extends ConsumerState<AccueilView> {
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).loadWalletData();
      ref.read(userProvider.notifier).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final formattedBalance = ref.watch(formattedBalanceProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    log("Formatted Balance User: $formattedBalance");
    if (currentUser != null) {
      log("--User Connecté: $currentUser");
      log("--User Connecté: ${currentUser.id}");
      log("--User Connecté Name: ${currentUser.fullName}");
      log("--User Connecté après l'appel du load user: $currentUser");
      log(
        "--User Connecté Name après l'appel du load user: ${currentUser.fullName}",
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildHeader(),
              _buildHeader(user: currentUser),
              SizedBox(height: 24),
              _buildBalanceCard(formattedBalance: formattedBalance),
              SizedBox(height: 24),
              buildQuickActions(context: context),
              SizedBox(height: 24),
              _buildCurrentChallenge(),
              SizedBox(height: 24),
              _buildSavingsVault(),
              SizedBox(height: 24),
              _buildRecentTransactions(
                recentTransactions: recentTransactions,
                currentUserId: currentUser != null ? currentUser.uuid : '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required UserModel? user}) {
    AuthService authService = AuthService();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50),
              ),
              child:
                  user?.hasProfilePicture == true
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          user!.profilePicture!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Center(
                        child: Text(
                          user?.initials ?? 'U',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user?.fullName ?? 'Chargement...',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        Row(
          children: [
            IconButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationsView()),
                  ),
              icon: Icon(Iconsax.notification, color: AppColors.textLight),
            ),
            IconButton(
              onPressed: () async {
                log("Help Me");
                await authService.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginView.idView,
                  (route) => false,
                );
              },
              icon: Image.asset("assets/icons/call-center.png", width: 26),
              // icon: Icon(Iconsax.message_question, color: AppColors.textLight),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard({required String formattedBalance}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, Color(0xFF0066FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde Principal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
                child: Icon(
                  _isBalanceVisible ? Iconsax.eye : Iconsax.eye_slash,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // SOLDE AVEC BOUTON DÉPÔT À CÔTÉ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SOLDE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isBalanceVisible ? formattedBalance : '•••••',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'CFA',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // BOUTON DÉPÔT INTÉGRÉ
              GestureDetector(
                onTap:
                    () => navigateWithTransition(
                      context: context,
                      page: DepositView(),
                      direction: TransitionDirection.rightToLeft,
                    ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    // color: const Color.fromARGB(255, 45, 45, 45),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.add_circle, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Déposer de l'argent",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // INFORMATIONS D'ÉPARGNE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceInfo(
                'Épargné ce mois',
                '15 420 CFA',
                Iconsax.trend_up,
              ),
              SizedBox(width: 24),
              _buildBalanceInfo('Objectif atteint', '75%', Iconsax.activity),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildBalanceCard({required String formattedBalance}) {
  //   return Container(
  //     width: double.infinity,
  //     padding: EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [AppColors.primaryLight, Color(0xFF0066FF)],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: AppColors.primaryLight.withOpacity(0.3),
  //           blurRadius: 20,
  //           offset: Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               'Solde Principal',
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(0.8),
  //                 fontSize: 14,
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   _isBalanceVisible = !_isBalanceVisible;
  //                 });
  //               },
  //               child: Icon(
  //                 _isBalanceVisible ? Iconsax.eye : Iconsax.eye_slash,
  //                 color: Colors.white,
  //                 size: 20,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 8),
  //         Text(
  //           _isBalanceVisible ? formattedBalance : '•••••',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 30,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         Text(
  //           'CFA',
  //           style: TextStyle(
  //             color: Colors.white.withOpacity(0.8),
  //             fontSize: 16,
  //           ),
  //         ),
  //         SizedBox(height: 16),
  //         Row(
  //           children: [
  //             _buildBalanceInfo(
  //               'Épargné ce mois',
  //               '15 420 CFA',
  //               Iconsax.trend_up,
  //             ),
  //             SizedBox(width: 24),
  //             _buildBalanceInfo('Objectif atteint', '75%', Iconsax.activity),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBalanceInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentChallenge() {
    return GestureDetector(
      onTap:
          () => navigateWithTransition(
            context: context,
            page: const ChallengeDetailsView(),
            direction: TransitionDirection.rightToLeft,
          ),

      child: Container(
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
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Iconsax.cup,
                          color: AppColors.accentLight,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Challenge de la semaine',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.visible, // pour bien afficher tout
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gap(15),
                // SizedBox(width: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🥉 Top 3',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Text(
              'Épargner 10 000 CFA en 7 jours',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '6 750 CFA / 10 000 CFA',
                  style: TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '2 jours restants',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.675,
              backgroundColor: AppColors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 6,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Voir le classement',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
                  child: Text('Épargner', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentChallenge() {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChallengeDetailsView()),
          ),
      child: Container(
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
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Iconsax.cup,
                        color: AppColors.accentLight,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Challenge collectif',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '🥉 3ème',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Épargner 10 000 CFA en 7 jours',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.675,
              backgroundColor: AppColors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsVault() {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VaultView()),
          ),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.safe_home,
                color: AppColors.secondaryLight,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coffre-fort caché',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Bloqué jusqu\'au 15 juillet 2025',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '••••• CFA',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions({
    required List<TransactionModel> recentTransactions,
    required String currentUserId,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions récentes',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed:
                  () => navigateWithTransition(
                    context: context,
                    page: TransactionsView(),
                  ),
              child: Text(
                'Voir tout',
                style: TextStyle(color: AppColors.primaryLight, fontSize: 14),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (recentTransactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '📭 Aucune transaction',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...recentTransactions.map(
            (transaction) => InkWell(
              onTap:
                  () => navigateWithTransition(
                    context: context,
                    page: TransactionDetailView(
                      transaction: transaction,
                      currentUserId: currentUserId,
                    ),
                  ),

              child: buildTransactionItem(
                // transaction.displayTitle,
                transaction.getDisplayTitle(currentUserId),
                transaction.getFormattedAmountForUser(currentUserId),
                transaction.createdAt.toString().substring(0, 19),
                transaction.transactionIcon,
                transaction.transactionColor,
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildTransactionItem(
  //   String title,
  //   String amount,
  //   String date,
  //   IconData icon,
  //   Color color,
  // ) {
  //   return Container(
  //     margin: EdgeInsets.only(bottom: 12),
  //     padding: EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: color.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(icon, color: color, size: 20),
  //         ),
  //         SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: TextStyle(
  //                   color: AppColors.textLight,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //               Text(
  //                 date,
  //                 style: TextStyle(
  //                   color: AppColors.textSecondaryLight,
  //                   fontSize: 12,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Text(
  //           amount,
  //           style: TextStyle(
  //             color:
  //                 amount.startsWith('+') ? AppColors.success : AppColors.error,
  //             fontSize: 14,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
