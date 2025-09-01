import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/viewmodels/user_view_model/user_provider.dart';
import 'package:akiba/viewmodels/wallet_view_model/wallet_provider.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/views/home/accueil_view.dart';
import 'package:akiba/views/home/home_view.dart';
import 'package:akiba/views/home/main_view.dart';
import 'package:akiba/widgets/components/show_custom_snack_bar.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class VerifyPinView extends ConsumerStatefulWidget {
  final String? returnRoute;

  const VerifyPinView({super.key, this.returnRoute});

  static const String idView = "verifypinview";

  @override
  ConsumerState<VerifyPinView> createState() => _VerifyPinViewState();
}

class _VerifyPinViewState extends ConsumerState<VerifyPinView> {
  String pin = '';
  bool isProcessing = false;
  int attemptCount = 0;
  static const int maxAttempts = 5;

  // Instance de AuthService
  final AuthService authService = AuthService();

  void onNumberPressed(String number) {
    if (isProcessing) return; // Empêcher les actions pendant le traitement

    setState(() {
      if (pin.length < 5) {
        pin += number;
        if (pin.length == 5) {
          _verifyPin(ref: ref);
        }
      }
    });
  }

  void onBackspacePressed() {
    if (isProcessing) return;

    setState(() {
      if (pin.isNotEmpty) {
        pin = pin.substring(0, pin.length - 1);
      }
    });
  }

  void _verifyPin({required WidgetRef ref}) async {
    setState(() {
      isProcessing = true;
    });

    bool success = await authService.verifyPin(
      pinCode: pin,
      context: context,
      ref: ref,
    );

    setState(() {
      isProcessing = false;
    });

    if (success) {
      if (widget.returnRoute != null) {
        Navigator.pushReplacementNamed(context, widget.returnRoute!);
      } else {
        navigateWithTransition(
          context: context,
          page: MainView(),
          direction: TransitionDirection.leftToRight,
          replace: true,
        );
      }
    } else {
      // PIN incorrect
      setState(() {
        attemptCount++;
        pin = '';
      });

      if (attemptCount >= maxAttempts) {
        _showMaxAttemptsDialog();
      }
      // else {
      //   showCustomSnackBar(
      //     context,
      //     isError: true,
      //     message:
      //         'Code PIN incorrect. ${maxAttempts - attemptCount} tentative(s) restante(s).',
      //   );
      // }
    }
  }

  void _showMaxAttemptsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône d'erreur
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                const Gap(20),
                const Text(
                  'Trop de tentatives',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                const Text(
                  'Vous avez dépassé le nombre maximum de tentatives. Veuillez vous reconnecter.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      authService.logout();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        LoginView.idView,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Se reconnecter',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PIN oublié ?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                const Text(
                  'Vous devrez vous reconnecter pour créer un nouveau PIN.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          authService.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginView.idView,
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).loadWalletData();
      ref.read(userProvider.notifier).loadUserProfile();
    });
    //   // Future.microtask(() {
    //   //   final notifier = ref.read(userProvider.notifier);
    //   //   if (!notifier.isUserLoaded && !ref.read(userProvider).isLoading) {
    //   //     notifier.loadUserProfile();
    //   //   }
    //   // });
  }

  @override
  Widget build(BuildContext context) {
    // final currentUser = ref.watch(currentUserProvider);
    // final formattedBalance = ref.watch(formattedBalanceProvider);
    // log("User Name dans le verify: ${currentUser?.fullName}");
    // log("User Balance Wallet dans le verify: $formattedBalance");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Gap(115),
              // Icône de verrouillage
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(61, 0, 82, 204),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const Gap(32),

              // Titre
              const Text(
                'Entrez votre PIN',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),

              // Sous-titre
              Text(
                'Saisissez votre code PIN pour accéder à votre compte',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              // Affichage du nombre de tentatives restantes si des erreurs
              const Gap(16),
              Text(
                '${maxAttempts - attemptCount} ${maxAttempts - attemptCount == 1 ? "tentative restante" : "tentatives restantes"}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange,
                ),
                textAlign: TextAlign.center,
              ),

              const Gap(60),

              // PIN dots indicator avec indicateur de traitement
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      bool isFilled = index < pin.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isFilled
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                          border: Border.all(
                            color:
                                isFilled
                                    ? AppColors.primaryLight
                                    : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                  // Indicateur de traitement
                  if (isProcessing)
                    Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryLight,
                        ),
                      ),
                    ),
                ],
              ),

              const Gap(80),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildForgotPinButton(),
            _buildKeypadButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildForgotPinButton() {
    return GestureDetector(
      onTap: _showForgotPinDialog,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: const Center(
          child: Text(
            'OUBLIÉ ?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: AppColors.primaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String number) {
    return GestureDetector(
      onTap: () => onNumberPressed(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isProcessing ? Colors.grey[100] : Colors.transparent,
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: isProcessing ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: onBackspacePressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isProcessing ? Colors.grey[100] : Colors.transparent,
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: isProcessing ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }
}
