// import 'package:akiba/constants/app_colors.dart';
// import 'package:flutter/material.dart';

// class TransferView extends StatelessWidget {
//   const TransferView({super.key});

//   static const String idView = "transferview";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Transférer'),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textLight,
//       ),
//       body: Center(
//         child: Text('Interface de transfert', style: TextStyle(fontSize: 18)),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/widgets/components/arrow_back.dart';
import 'package:akiba/viewmodels/user_view_model/user_provider.dart';
import 'package:akiba/services/wallet_service/wallet_service.dart';

class TransferView extends ConsumerStatefulWidget {
  const TransferView({super.key});

  static const String idView = "transferview";

  @override
  ConsumerState<TransferView> createState() => _TransferViewState();
}

class _TransferViewState extends ConsumerState<TransferView> {
  final _formKey = GlobalKey<FormState>();
  final _receiverPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentBalance();
  }

  Future<void> _loadCurrentBalance() async {
    try {
      final walletService = WalletService();
      final balance = await walletService.checkBalance();
      if (mounted) {
        setState(() {
          _currentBalance = balance ?? 0.0;
        });
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    }
  }

  @override
  void dispose() {
    _receiverPhoneController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transférer'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        leading: arrowBack(onTap: () => Navigator.pop(context)),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header avec information transfert
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: AppColors.primaryLight,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transfert d\'argent',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              'Envoyez de l\'argent à un autre utilisateur',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondaryLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Solde disponible
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Solde disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '${_currentBalance.toStringAsFixed(0)} CFA',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Champ destinataire
                const Text(
                  'Numéro du destinataire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _receiverPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+225 XX XX XX XX XX',
                    prefixIcon: const Icon(
                      Icons.person,
                      color: AppColors.primaryLight,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.contacts,
                        color: AppColors.primaryLight,
                      ),
                      onPressed: () {
                        // Ouvrir le carnet d'adresses
                        _showContactPicker();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir le numéro du destinataire';
                    }
                    if (value.length < 8) {
                      return 'Numéro invalide';
                    }

                    // Vérifier que ce n'est pas son propre numéro
                    final currentUser = ref.read(currentUserProvider);
                    if (currentUser != null &&
                        value == currentUser.phoneNumber) {
                      return 'Impossible de transférer à soi-même';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Champ montant
                const Text(
                  'Montant à transférer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: 'CFA',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: AppColors.primaryLight,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir le montant';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Montant invalide';
                    }
                    if (amount < 100) {
                      return 'Montant minimum : 100 CFA';
                    }
                    if (amount > _currentBalance) {
                      return 'Solde insuffisant';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Champ message (optionnel)
                // const Text(
                //   'Message (optionnel)',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w500,
                //     color: AppColors.textLight,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // TextFormField(
                //   controller: _messageController,
                //   maxLines: 3,
                //   decoration: InputDecoration(
                //     hintText: 'Ajouter un message...',
                //     prefixIcon: const Icon(
                //       Icons.message,
                //       color: AppColors.primaryLight,
                //     ),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide(color: Colors.grey.shade300),
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide(color: Colors.grey.shade300),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: const BorderSide(
                //         color: AppColors.primaryLight,
                //       ),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 32),

                // Montants rapides
                const Text(
                  'Montants rapides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      _getQuickAmounts()
                          .map((amount) => _buildQuickAmountChip(amount))
                          .toList(),
                ),

                const SizedBox(height: 32),

                // Contacts récents (si vous avez cette fonctionnalité)
                // const Text(
                //   'Transferts récents',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w500,
                //     color: AppColors.textLight,
                //   ),
                // ),
                // const SizedBox(height: 12),
                // _buildRecentTransfers(),

                // const SizedBox(height: 40),

                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Confirmer le transfert',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<int> _getQuickAmounts() {
    final amounts = <int>[];
    final balance = _currentBalance.toInt();

    if (balance >= 1000) amounts.add(1000);
    if (balance >= 2500) amounts.add(2500);
    if (balance >= 5000) amounts.add(5000);
    if (balance >= 10000) amounts.add(10000);
    if (balance >= 25000) amounts.add(25000);
    if (balance >= 50000) amounts.add(50000);

    return amounts;
  }

  Widget _buildQuickAmountChip(int amount) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount.toString();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: Text(
          '${amount.toString()} CFA',
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Widget _buildRecentTransfers() {
  //   // Ici vous pouvez récupérer les transferts récents depuis votre provider
  //   // Pour l'instant, affichons un placeholder
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: Colors.grey.shade200),
  //     ),
  //     child: const Text(
  //       'Aucun transfert récent',
  //       style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
  //       textAlign: TextAlign.center,
  //     ),
  //   );
  // }

  void _showContactPicker() {
    // Placeholder pour ouvrir le carnet d'adresses
    // Vous pouvez implémenter cette fonctionnalité avec un package comme contacts_service
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Carnet d\'adresses'),
            content: const Text('Fonctionnalité à implémenter'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showTransferConfirmation() {
    final amount = double.parse(_amountController.text);
    final receiverPhone = _receiverPhoneController.text;
    final message = _messageController.text;

    // showDialog(
    //   context: context,
    //   builder:
    //       (context) => AlertDialog(
    //         title: const Text('Confirmer le transfert'),
    //         content: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text('Destinataire: $receiverPhone'),
    //             const SizedBox(height: 8),
    //             Text('Montant: ${amount.toStringAsFixed(0)} CFA'),
    //             if (message.isNotEmpty) ...[
    //               const SizedBox(height: 8),
    //               Text('Message: $message'),
    //             ],
    //           ],
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.pop(context),
    //             child: const Text('Annuler'),
    //           ),
    //           ElevatedButton(
    //             onPressed: () {
    //               Navigator.pop(context);
    //               _performTransfer();
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: AppColors.primaryLight,
    //             ),
    //             child: const Text('Confirmer'),
    //           ),
    //         ],
    //       ),
    // );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Confirmer le transfert',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Destinataire : $receiverPhone'),
                const SizedBox(height: 8),
                Text('Montant : ${amount.toStringAsFixed(0)} CFA'),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Message : $message'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _performTransfer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    _showTransferConfirmation();
  }

  void _performTransfer() async {
    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final receiverPhone = _receiverPhoneController.text;
      final message =
          _messageController.text.isNotEmpty ? _messageController.text : null;

      // Appeler votre WalletService
      final walletService = WalletService();
      final result = await walletService.makeTransfer(
        receiverPhoneNumber: receiverPhone,
        amount: amount,
        message: message,
      );

      if (mounted && result != null) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transfert de ${amount.toStringAsFixed(0)} CFA effectué avec succès',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Vider les champs
        _receiverPhoneController.clear();
        _amountController.clear();
        _messageController.clear();

        // Retourner à l'écran précédent
        Navigator.of(
          context,
        ).popUntil((route) => route.settings.name == '/home' || route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
