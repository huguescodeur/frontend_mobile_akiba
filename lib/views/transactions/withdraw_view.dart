// import 'package:akiba/constants/app_colors.dart';
// import 'package:flutter/material.dart';

// class WithdrawView extends StatelessWidget {
//   const WithdrawView({super.key});

//   static const String idView = "withdrawview";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Effectuer un retrait'),
//         backgroundColor: Colors.white,
//         foregroundColor: AppColors.textLight,
//       ),
//       body: Center(
//         child: Text('Interface de retrait', style: TextStyle(fontSize: 18)),
//       ),
//     );
//   }
// }

import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/widgets/components/arrow_back.dart';
import 'package:akiba/viewmodels/user_view_model/user_provider.dart';
import 'package:akiba/services/wallet_service/wallet_service.dart';

class WithdrawView extends StatelessWidget {
  const WithdrawView({super.key});

  static const String idView = "withdrawview";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Effectuer un retrait'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        leading: arrowBack(onTap: () => Navigator.pop(context)),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choisissez votre opérateur',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez l\'opérateur avec lequel vous souhaitez effectuer votre retrait',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildOperatorCard(
                      context: context,
                      operatorName: 'Wave',
                      operatorLogo: 'assets/images/wave.png',
                      operatorColor: const Color(0xFF00B4D8),
                      onTap: () => _navigateToWithdrawForm(context, 'Wave'),
                    ),
                    _buildOperatorCard(
                      context: context,
                      operatorName: 'MTN',
                      operatorLogo: 'assets/images/mtn.png',
                      operatorColor: const Color(0xFFFFCC00),
                      onTap: () => _navigateToWithdrawForm(context, 'MTN'),
                    ),
                    _buildOperatorCard(
                      context: context,
                      operatorName: 'Moov',
                      operatorLogo: 'assets/images/moov.png',
                      operatorColor: const Color(0xFF00A651),
                      onTap: () => _navigateToWithdrawForm(context, 'Moov'),
                    ),
                    _buildOperatorCard(
                      context: context,
                      operatorName: 'Orange',
                      operatorLogo: 'assets/images/orange.png',
                      operatorColor: const Color(0xFFFF6600),
                      onTap: () => _navigateToWithdrawForm(context, 'Orange'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperatorCard({
    required BuildContext context,
    required String operatorName,
    required String operatorLogo,
    required Color operatorColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: operatorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                // Text(
                //   operatorName[0],
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.bold,
                //     color: operatorColor,
                //   ),
                // ),
                // Si vous avez les logos, remplacez par :
                Image.asset(operatorLogo, width: 40, height: 40),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              operatorName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Retrait via $operatorName',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToWithdrawForm(BuildContext context, String operator) {
    navigateWithTransition(
      context: context,
      page: WithdrawFormView(operator: operator),
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => WithdrawFormView(operator: operator),
    //   ),
    // );
  }
}

class WithdrawFormView extends ConsumerStatefulWidget {
  final String operator;

  const WithdrawFormView({super.key, required this.operator});

  @override
  ConsumerState<WithdrawFormView> createState() => _WithdrawFormViewState();
}

class _WithdrawFormViewState extends ConsumerState<WithdrawFormView> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _isLoading = false;
  double _currentBalance = 0.0;

  // Couleurs par opérateur
  Color get _operatorColor {
    switch (widget.operator) {
      case 'Wave':
        return const Color(0xFF00B4D8);
      case 'MTN':
        return const Color(0xFFFFCC00);
      case 'Moov':
        return const Color(0xFF00A651);
      case 'Orange':
        return const Color(0xFFFF6600);
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec le numéro de l'utilisateur actuel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        _phoneController.text = currentUser.phoneNumber;
      } else {
        _phoneController.text = "+225"; // Fallback
      }
      _loadCurrentBalance();
    });
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
    _phoneController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retrait ${widget.operator}'),
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
                // Header avec opérateur
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _operatorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _operatorColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            widget.operator[0],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _operatorColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Retrait via ${widget.operator}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              'Renseignez les informations de votre retrait',
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

                const SizedBox(height: 24),

                // Champ numéro de téléphone
                const Text(
                  'Numéro de téléphone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+225 XX XX XX XX XX',
                    prefixIcon: Icon(Icons.phone, color: _operatorColor),
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
                      borderSide: BorderSide(color: _operatorColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir votre numéro';
                    }
                    if (value.length < 8) {
                      return 'Numéro invalide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Champ montant
                const Text(
                  'Montant à retirer',
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
                    prefixIcon: Icon(Icons.money_off, color: _operatorColor),
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
                      borderSide: BorderSide(color: _operatorColor),
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

                // Champ référence (optionnel)
                // const Text(
                //   'Référence (optionnel)',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w500,
                //     color: AppColors.textLight,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // TextFormField(
                //   controller: _referenceController,
                //   decoration: InputDecoration(
                //     hintText: 'Référence de transaction',
                //     prefixIcon: Icon(Icons.receipt, color: _operatorColor),
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
                //       borderSide: BorderSide(color: _operatorColor),
                //     ),
                //   ),
                // ),

                // const SizedBox(height: 32),

                // Montants rapides (basés sur le solde disponible)
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

                const SizedBox(height: 40),

                // Bouton de confirmation
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleWithdraw,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _operatorColor,
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
                              'Confirmer le retrait',
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
    // Générer des montants rapides basés sur le solde disponible
    final amounts = <int>[];
    final balance = _currentBalance.toInt();

    if (balance >= 1000) amounts.add(1000);
    if (balance >= 2500) amounts.add(2500);
    if (balance >= 5000) amounts.add(5000);
    if (balance >= 10000) amounts.add(10000);
    if (balance >= 25000) amounts.add(25000);
    if (balance >= 50000) amounts.add(50000);

    // Ajouter un montant pour "tout retirer" si le solde > 100
    if (balance > 100) {
      amounts.add(balance);
    }

    return amounts;
  }

  Widget _buildQuickAmountChip(int amount) {
    final isMaxAmount = amount == _currentBalance.toInt();
    return GestureDetector(
      onTap: () {
        _amountController.text = amount.toString();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isMaxAmount
                  ? _operatorColor.withOpacity(0.2)
                  : _operatorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isMaxAmount ? _operatorColor : _operatorColor.withOpacity(0.3),
          ),
        ),
        child: Text(
          isMaxAmount
              ? 'Tout (${amount.toString()} CFA)'
              : '${amount.toString()} CFA',
          style: TextStyle(
            color: _operatorColor,
            fontWeight: FontWeight.w500,
            fontSize: isMaxAmount ? 12 : 14,
          ),
        ),
      ),
    );
  }

  void _handleWithdraw() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final phone = _phoneController.text;
      final reference =
          _referenceController.text.isNotEmpty
              ? _referenceController.text
              : null;

      // Appeler votre WalletService
      final walletService = WalletService();
      final result = await walletService.makeWithdrawal(
        amount: amount,
        operator: widget.operator,
        reference: reference,
      );

      if (mounted && result != null) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Retrait de ${amount.toStringAsFixed(0)} CFA effectué avec succès',
            ),
            backgroundColor: AppColors.success,
          ),
        );

        // Retourner à l'écran précédent
        Navigator.of(
          context,
        ).popUntil((route) => route.settings.name == '/home' || route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du retrait: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
