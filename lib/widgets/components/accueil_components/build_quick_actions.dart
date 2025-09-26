import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/views/transactions/deposit_view.dart';
import 'package:akiba/views/transactions/transfer_view.dart';
import 'package:akiba/views/transactions/withdraw_view.dart';
import 'package:akiba/views/vault/vault_view.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Widget buildQuickActions({required BuildContext context}) {
//   final actions = [
//     {
//       'title': 'Dépôt',
//       'icon': Iconsax.add_circle,
//       'color': AppColors.success,
//       'route': DepositView(),
//     },
//     {
//       'title': 'Retrait',
//       'icon': Iconsax.minus_cirlce,
//       'color': AppColors.error,
//       'route': WithdrawView(),
//     },
//     {
//       'title': 'Transfert',
//       'icon': Iconsax.send_2,
//       'color': AppColors.primaryLight,
//       'route': TransferView(),
//     },
//     {
//       'title': 'Coffre-fort',
//       'icon': Iconsax.safe_home,
//       'color': AppColors.accentLight,
//       'route': VaultView(),
//     },
//   ];

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Actions rapides',
//         style: TextStyle(
//           color: AppColors.textLight,
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       SizedBox(height: 16),
//       Row(
//         children:
//             actions
//                 .map(
//                   (action) => Expanded(
//                     child: Padding(
//                       padding: EdgeInsets.only(right: 12),
//                       child: GestureDetector(
//                         onTap:
//                             () => navigateWithTransition(
//                               context: context,
//                               page: action['route'] as Widget,
//                               direction: TransitionDirection.rightToLeft,
//                             ),

//                         child: Container(
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 10,
//                                 offset: Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             children: [
//                               Container(
//                                 padding: EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: (action['color'] as Color).withOpacity(
//                                     0.1,
//                                   ),
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Icon(
//                                   action['icon'] as IconData,
//                                   color: action['color'] as Color,
//                                   size: 24,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 action['title'] as String,
//                                 style: TextStyle(
//                                   color: AppColors.textLight,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 )
//                 .toList(),
//       ),
//     ],
//   );
// }

Widget buildQuickActions({required BuildContext context}) {
  final actions = [
    {
      'title': 'Retrait',
      'icon': Iconsax.minus_cirlce,
      'color': AppColors.error,
      'route': WithdrawView(),
    },
    {
      'title': 'Transfert',
      'icon': Iconsax.send_2,
      'color': AppColors.primaryLight,
      'route': TransferView(),
    },
    {
      'title': 'Coffre-fort',
      'icon': Iconsax.safe_home,
      'color': AppColors.accentLight,
      'route': VaultView(),
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Actions rapides',
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 16),
      Row(
        children:
            actions
                .map(
                  (action) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            actions.indexOf(action) == actions.length - 1
                                ? 0
                                : 12,
                      ),
                      child: GestureDetector(
                        onTap:
                            () => navigateWithTransition(
                              context: context,
                              page: action['route'] as Widget,
                              direction: TransitionDirection.rightToLeft,
                            ),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
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
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (action['color'] as Color).withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  action['icon'] as IconData,
                                  color: action['color'] as Color,
                                  size: 24,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                action['title'] as String,
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    ],
  );
}
