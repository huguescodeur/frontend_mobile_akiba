// import 'package:akiba/constants/app_colors.dart';
// import 'package:flutter/material.dart';

// class TransactionsView extends StatelessWidget {
//   const TransactionsView({super.key});

//   static const String idView = "transactionsview";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Toutes les transactions'),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textLight,
//       ),
//       body: Center(
//         child: Text(
//           'Historique complet des transactions',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/viewmodels/user_view_model/user_provider.dart';
import 'package:akiba/viewmodels/wallet_view_model/wallet_provider.dart';
import 'package:akiba/views/transactions/transaction_detail_view.dart';
import 'package:akiba/widgets/components/arrow_back.dart';
import 'package:akiba/widgets/components/build_transaction_item.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionsView extends ConsumerWidget {
  const TransactionsView({super.key});

  static const String idView = "transactionsview";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final allTransactions = ref.watch(allTransactionsProvider);
    // 👆 utilise le provider qui contient la liste complète

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les transactions'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
        leading: arrowBack(onTap: () => Navigator.pop(context)),
      ),
      body:
          allTransactions.isEmpty
              ? const Center(
                child: Text(
                  '📭 Aucune transaction',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
              : SafeArea(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: allTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final transaction = allTransactions[index];
                    return InkWell(
                      onTap:
                          () => navigateWithTransition(
                            context: context,
                            page: TransactionDetailView(
                              transaction: transaction,
                              currentUserId: currentUser?.uuid ?? "",
                            ),
                          ),

                      child: buildTransactionItem(
                        transaction.getDisplayTitle(currentUser?.uuid ?? ""),
                        transaction.getFormattedAmountForUser(
                          currentUser?.uuid ?? "",
                        ),
                        transaction.createdAt.toString().substring(0, 19),
                        transaction.transactionIcon,
                        transaction.transactionColor,
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
