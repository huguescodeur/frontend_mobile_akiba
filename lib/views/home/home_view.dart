import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/views/challenge/challenge_details_view.dart';
import 'package:akiba/views/notifications/notifications_view.dart';
import 'package:akiba/views/settings/settings_view.dart';
import 'package:akiba/views/transactions/transactions_view.dart';
import 'package:akiba/views/vault/vault_view.dart';
import 'package:akiba/widgets/components/accueil_components/build_quick_actions.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   static const String idView = "homeview";

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
//   bool _isBalanceVisible = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               SizedBox(height: 24),
//               _buildBalanceCard(),
//               SizedBox(height: 24),
//               buildQuickActions(context: context),
//               SizedBox(height: 24),
//               _buildCurrentChallenge(),
//               SizedBox(height: 24),
//               _buildSavingsVault(),
//               SizedBox(height: 24),
//               _buildRecentTransactions(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Container(
//               height: 40,
//               width: 40,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(50),
//                 image: DecorationImage(
//                   image: AssetImage("assets/images/hugues.png"),
//                 ),
//               ),
//             ),
//             SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Bonjour,',
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 14,
//                   ),
//                 ),
//                 Text(
//                   'Goli Yao Hugues',
//                   style: TextStyle(
//                     color: AppColors.textLight,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             IconButton(
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => NotificationsView()),
//                   ),
//               icon: Icon(Iconsax.notification, color: AppColors.textLight),
//             ),
//             IconButton(
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => SettingsView()),
//                   ),
//               icon: Icon(Iconsax.setting, color: AppColors.textLight),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildBalanceCard() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.primaryLight, Color(0xFF0066FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryLight.withOpacity(0.3),
//             blurRadius: 20,
//             offset: Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Solde Principal',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 14,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _isBalanceVisible = !_isBalanceVisible;
//                   });
//                 },
//                 child: Icon(
//                   _isBalanceVisible ? Iconsax.eye : Iconsax.eye_slash,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             _isBalanceVisible ? '47 325 546 987 987' : '•••••',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             'CFA',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               _buildBalanceInfo(
//                 'Épargné ce mois',
//                 '15 420 CFA',
//                 Iconsax.trend_up,
//               ),
//               SizedBox(width: 24),
//               _buildBalanceInfo('Objectif atteint', '75%', Iconsax.activity),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBalanceInfo(String label, String value, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: Colors.white, size: 16),
//         ),
//         SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 11,
//               ),
//             ),
//             Text(
//               value,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildCurrentChallenge() {
//     return GestureDetector(
//       onTap:
//           () => navigateWithTransition(
//             context: context,
//             page: const ChallengeDetailsView(),
//             direction: TransitionDirection.rightToLeft,
//           ),

//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: AppColors.accentLight.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Icon(
//                           Iconsax.cup,
//                           color: AppColors.accentLight,
//                           size: 20,
//                         ),
//                       ),
//                       SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Challenge de la semaine',
//                           style: TextStyle(
//                             color: AppColors.textLight,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           maxLines: 1,
//                           overflow:
//                               TextOverflow.visible, // pour bien afficher tout
//                           softWrap: false,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Gap(15),
//                 // SizedBox(width: 20),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.success.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '🥉 Top 3',
//                     style: TextStyle(
//                       color: AppColors.success,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(height: 16),
//             Text(
//               'Épargner 10 000 CFA en 7 jours',
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '6 750 CFA / 10 000 CFA',
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 12,
//                   ),
//                 ),
//                 Text(
//                   '2 jours restants',
//                   style: TextStyle(
//                     color: AppColors.primaryLight,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             LinearProgressIndicator(
//               value: 0.675,
//               backgroundColor: AppColors.grey,
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
//               minHeight: 6,
//             ),
//             SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 TextButton(
//                   onPressed: () {},
//                   child: Text(
//                     'Voir le classement',
//                     style: TextStyle(
//                       color: AppColors.primaryLight,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryLight,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text('Épargner', style: TextStyle(fontSize: 12)),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildCurrentChallenge() {
//     return GestureDetector(
//       onTap:
//           () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => ChallengeDetailsView()),
//           ),
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: AppColors.accentLight.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         Iconsax.cup,
//                         color: AppColors.accentLight,
//                         size: 20,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Challenge collectif',
//                       style: TextStyle(
//                         color: AppColors.textLight,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppColors.success.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '🥉 3ème',
//                     style: TextStyle(
//                       color: AppColors.success,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Épargner 10 000 CFA en 7 jours',
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8),
//             LinearProgressIndicator(
//               value: 0.675,
//               backgroundColor: AppColors.grey,
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSavingsVault() {
//     return GestureDetector(
//       onTap:
//           () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => VaultView()),
//           ),
//       child: Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.secondaryLight.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(
//                 Iconsax.safe_home,
//                 color: AppColors.secondaryLight,
//                 size: 24,
//               ),
//             ),
//             SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Coffre-fort caché',
//                     style: TextStyle(
//                       color: AppColors.textLight,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   Text(
//                     'Bloqué jusqu\'au 15 juillet 2025',
//                     style: TextStyle(
//                       color: AppColors.textSecondaryLight,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Text(
//               '••••• CFA',
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentTransactions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Transactions récentes',
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             TextButton(
//               onPressed:
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => TransactionsView()),
//                   ),
//               child: Text(
//                 'Voir tout',
//                 style: TextStyle(color: AppColors.primaryLight, fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         _buildTransactionItem(
//           'Dépôt Wave',
//           '+ 25 000 CFA',
//           'Aujourd\'hui',
//           Iconsax.add_circle,
//           AppColors.success,
//         ),
//         _buildTransactionItem(
//           'Challenge réussi',
//           '+ 500 CFA',
//           'Hier',
//           Iconsax.cup,
//           AppColors.accentLight,
//         ),
//         _buildTransactionItem(
//           'Retrait MTN',
//           '- 5 000 CFA',
//           'Il y a 2 jours',
//           Iconsax.minus_cirlce,
//           AppColors.error,
//         ),
//       ],
//     );
//   }

//   Widget _buildTransactionItem(
//     String title,
//     String amount,
//     String date,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: AppColors.textLight,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   date,
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             amount,
//             style: TextStyle(
//               color:
//                   amount.startsWith('+') ? AppColors.success : AppColors.error,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   static const String idView = "homeview";

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
//   int _currentIndex = 0;
//   bool _isBalanceVisible = true;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: AppColors.backgroundLight,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               SizedBox(height: 24),
//               _buildBalanceCard(),
//               SizedBox(height: 24),
//               _buildQuickActions(),
//               SizedBox(height: 24),
//               _buildCurrentChallenge(),
//               SizedBox(height: 24),
//               _buildSavingsVault(),
//               SizedBox(height: 24),
//               _buildRecentTransactions(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNavigation(),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Container(
//               height: 40,
//               width: 40,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(50),
//                 image: DecorationImage(
//                   image: AssetImage("assets/images/hugues.png"),
//                 ),
//               ),
//             ),

//             SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Bonjour,',
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 14,
//                   ),
//                 ),
//                 Text(
//                   'Goli Yao Hugues',
//                   style: TextStyle(
//                     color: AppColors.textLight,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Iconsax.notification, color: AppColors.textLight),
//             ),
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Iconsax.setting, color: AppColors.textLight),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildBalanceCard() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [AppColors.primaryLight, Color(0xFF0066FF)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryLight.withOpacity(0.3),
//             blurRadius: 20,
//             offset: Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Solde Principal',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.8),
//                   fontSize: 14,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _isBalanceVisible = !_isBalanceVisible;
//                   });
//                 },
//                 child: Icon(
//                   _isBalanceVisible ? Iconsax.eye : Iconsax.eye_slash,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             _isBalanceVisible ? '47 325 546 987 987' : '•••••',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 30,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             'CFA',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: 16),
//           Row(
//             children: [
//               _buildBalanceInfo(
//                 'Épargné ce mois',
//                 '15 420 CFA',
//                 Iconsax.trend_up,
//               ),
//               SizedBox(width: 24),
//               _buildBalanceInfo('Objectif atteint', '75%', Iconsax.activity),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBalanceInfo(String label, String value, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: Colors.white, size: 16),
//         ),
//         SizedBox(width: 8),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.7),
//                 fontSize: 11,
//               ),
//             ),
//             Text(
//               value,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Actions rapides',
//           style: TextStyle(
//             color: AppColors.textLight,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildActionCard(
//                 'Dépôt',
//                 Iconsax.add_circle,
//                 AppColors.success,
//               ),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: _buildActionCard(
//                 'Retrait',
//                 Iconsax.minus_cirlce,
//                 AppColors.error,
//               ),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: _buildActionCard(
//                 'Transfert',
//                 Iconsax.send_2,
//                 AppColors.primaryLight,
//               ),
//             ),
//             SizedBox(width: 12),
//             Expanded(
//               child: _buildActionCard(
//                 'Objectifs',
//                 Iconsax.activity,
//                 AppColors.accentLight,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionCard(String title, IconData icon, Color color) {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 24),
//             ),
//             SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentChallenge() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: AppColors.accentLight.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         Iconsax.cup,
//                         color: AppColors.accentLight,
//                         size: 20,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Challenge de la semaine',
//                         style: TextStyle(
//                           color: AppColors.textLight,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         maxLines: 1,
//                         overflow:
//                             TextOverflow.visible, // pour bien afficher tout
//                         softWrap: false,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Gap(15),
//               // SizedBox(width: 20),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.success.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '🥉 Top 3',
//                   style: TextStyle(
//                     color: AppColors.success,
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(height: 16),
//           Text(
//             'Épargner 10 000 CFA en 7 jours',
//             style: TextStyle(
//               color: AppColors.textLight,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 '6 750 CFA / 10 000 CFA',
//                 style: TextStyle(
//                   color: AppColors.textSecondaryLight,
//                   fontSize: 12,
//                 ),
//               ),
//               Text(
//                 '2 jours restants',
//                 style: TextStyle(
//                   color: AppColors.primaryLight,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           LinearProgressIndicator(
//             value: 0.675,
//             backgroundColor: AppColors.grey,
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
//             minHeight: 6,
//           ),
//           SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextButton(
//                 onPressed: () {},
//                 child: Text(
//                   'Voir le classement',
//                   style: TextStyle(
//                     color: AppColors.primaryLight,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryLight,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: Text('Épargner', style: TextStyle(fontSize: 12)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSavingsVault() {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.secondaryLight.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               Iconsax.safe_home,
//               color: AppColors.secondaryLight,
//               size: 24,
//             ),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Coffre-fort caché',
//                   style: TextStyle(
//                     color: AppColors.textLight,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   'Bloqué jusqu\'au 15 juillet 2025',
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '••••• CFA',
//                 style: TextStyle(
//                   color: AppColors.textLight,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 '23 jours restants',
//                 style: TextStyle(
//                   color: AppColors.primaryLight,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentTransactions() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Transactions récentes',
//               style: TextStyle(
//                 color: AppColors.textLight,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             TextButton(
//               onPressed: () {},
//               child: Text(
//                 'Voir tout',
//                 style: TextStyle(color: AppColors.primaryLight, fontSize: 14),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         _buildTransactionItem(
//           'Dépôt Wave',
//           '+ 25 000 CFA',
//           'Aujourd\'hui',
//           Iconsax.add_circle,
//           AppColors.success,
//         ),
//         _buildTransactionItem(
//           'Challenge réussi',
//           '+ 500 CFA',
//           'Hier',
//           Iconsax.cup,
//           AppColors.accentLight,
//         ),
//         _buildTransactionItem(
//           'Retrait MTN',
//           '- 5 000 CFA',
//           'Il y a 2 jours',
//           Iconsax.minus_cirlce,
//           AppColors.error,
//         ),
//       ],
//     );
//   }

//   Widget _buildTransactionItem(
//     String title,
//     String amount,
//     String date,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: AppColors.textLight,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Text(
//                   date,
//                   style: TextStyle(
//                     color: AppColors.textSecondaryLight,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             amount,
//             style: TextStyle(
//               color:
//                   amount.startsWith('+') ? AppColors.success : AppColors.error,
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavigation() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20,
//             offset: Offset(0, -5),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: AppColors.primaryLight,
//         unselectedItemColor: AppColors.textSecondaryLight,
//         selectedLabelStyle: TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//         unselectedLabelStyle: TextStyle(fontSize: 12),
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Iconsax.home),
//             activeIcon: Icon(Iconsax.home),
//             label: 'Accueil',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Iconsax.chart_1),
//             activeIcon: Icon(Iconsax.chart_1),
//             label: 'Statistiques',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Iconsax.people),
//             activeIcon: Icon(Iconsax.people),
//             label: 'Communauté',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Iconsax.activity),
//             activeIcon: Icon(Iconsax.activity),
//             label: 'Objectifs',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Iconsax.profile_circle),
//             activeIcon: Icon(Iconsax.profile_circle),
//             label: 'Profil',
//           ),
//         ],
//       ),
//     );
//   }
// }
