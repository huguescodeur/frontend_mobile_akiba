import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/views/home/accueil_view.dart';
import 'package:akiba/widgets/components/arrow_back.dart';
import 'package:akiba/widgets/components/show_custom_snack_bar.dart';
import 'package:akiba/widgets/components/show_success_dialog.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CreatePinView extends StatefulWidget {
  const CreatePinView({super.key});

  static const String idView = "createpinview";

  @override
  State<CreatePinView> createState() => _CreatePinViewState();
}

class _CreatePinViewState extends State<CreatePinView> {
  String pin = '';
  String confirmPin = '';
  bool isConfirmingPin = false;
  bool isProcessing = false;

  // Instance de AuthService
  final AuthService authService = AuthService();

  void onNumberPressed(String number) {
    if (isProcessing) return; // Empêcher les actions pendant le traitement

    setState(() {
      if (!isConfirmingPin) {
        if (pin.length < 4) {
          pin += number;
          if (pin.length == 4) {
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                isConfirmingPin = true;
              });
            });
          }
        }
      } else {
        if (confirmPin.length < 4) {
          confirmPin += number;
          if (confirmPin.length == 4) {
            _verifyPins();
          }
        }
      }
    });
  }

  void onBackspacePressed() {
    if (isProcessing) return; // Empêcher les actions pendant le traitement

    setState(() {
      if (!isConfirmingPin) {
        if (pin.isNotEmpty) {
          pin = pin.substring(0, pin.length - 1);
        }
      } else {
        if (confirmPin.isNotEmpty) {
          confirmPin = confirmPin.substring(0, confirmPin.length - 1);
        } else {
          isConfirmingPin = false;
          pin = '';
        }
      }
    });
  }

  void _verifyPins() async {
    if (pin != confirmPin) {
      showCustomSnackBar(
        context,
        isError: true,
        message: 'Les codes PIN ne correspondent pas. Veuillez réessayer.',
      );
      setState(() {
        pin = '';
        confirmPin = '';
        isConfirmingPin = false;
      });
      return;
    }

    setState(() {
      isProcessing = true;
    });

    // Utiliser AuthService pour créer le PIN
    bool success = await authService.createPin(
      pinCode: pin,
      confirmPinCode: confirmPin,
      context: context,
    );

    setState(() {
      isProcessing = false;
    });

    if (success) {
      _showSuccessDialog();
    } else {
      // Reset en cas d'erreur
      setState(() {
        pin = '';
        confirmPin = '';
        isConfirmingPin = false;
      });
    }
  }

  void _showSuccessDialog() {
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
                // Icône de succès
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                const Gap(20),
                const Text(
                  'PIN créé !',
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
                  'Votre code PIN a été créé avec succès.',
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
                      Navigator.of(context).pop();

                      navigateWithTransition(
                        context: context,
                        page: const AccueilView(), // ou votre page principale
                        direction: TransitionDirection.rightToLeft,
                        replace: true,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuer',
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

  @override
  Widget build(BuildContext context) {
    String currentPin = isConfirmingPin ? confirmPin : pin;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Gap(100),
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
              Text(
                isConfirmingPin ? 'Confirmer le PIN' : 'Créer un PIN',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                isConfirmingPin
                    ? 'Entrez à nouveau votre code PIN'
                    : 'Définir un code PIN pour votre compte',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryLight,
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
                    children: List.generate(4, (index) {
                      bool isFilled = index < currentPin.length;
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
                  // Gap(10),
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
            const SizedBox(width: 70, height: 70),
            _buildKeypadButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
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
