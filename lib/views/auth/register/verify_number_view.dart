import 'dart:async';
import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/views/auth/register/create_pin_view.dart';
import 'package:akiba/widgets/components/arrow_back.dart';
import 'package:akiba/widgets/components/custom_button.dart';
import 'package:akiba/widgets/components/register/verify_code_widget.dart';
import 'package:akiba/widgets/components/show_custom_snack_bar.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class VerifyNumberView extends StatefulWidget {
  final String? phoneNumber;

  static const String idView = "verifynumberview";

  const VerifyNumberView({super.key, this.phoneNumber});

  @override
  State<VerifyNumberView> createState() => _VerifyNumberViewState();
}

class _VerifyNumberViewState extends State<VerifyNumberView> {
  String enteredCode = '';
  int resendTimer = 59;
  Timer? timer;
  bool isVerifying = false;

  // Instance de AuthService
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() {
          resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void onNumberPressed(String number) {
    if (enteredCode.length < 6 && !isVerifying) {
      setState(() {
        enteredCode += number;
      });

      // Si on a 6 chiffres, démarrer la vérification
      if (enteredCode.length == 6) {
        _startVerification();
      }
    }
  }

  void onBackspacePressed() {
    if (enteredCode.isNotEmpty && !isVerifying) {
      setState(() {
        enteredCode = enteredCode.substring(0, enteredCode.length - 1);
      });
    }
  }

  void _startVerification() async {
    setState(() {
      isVerifying = true;
    });

    // Utiliser AuthService pour vérifier le code
    bool isVerified = await authService.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber ?? '',
      verificationCode: enteredCode,
      context: context,
    );

    setState(() {
      isVerifying = false;
    });

    if (isVerified) {
      _showSuccessDialog();
    } else {
      // Reset le code en cas d'erreur
      setState(() {
        enteredCode = '';
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
                  'Numéro vérifié !',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                Text(
                  'Votre numéro ${widget.phoneNumber} a été vérifié avec succès.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondaryLight,
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
                        page: CreatePinView(),
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

  void resendCode() async {
    if (resendTimer == 0) {
      // Utiliser AuthService pour renvoyer le code
      bool success = await authService.resendVerificationCode(
        phoneNumber: widget.phoneNumber ?? '',
        context: context,
      );

      if (success) {
        setState(() {
          resendTimer = 59;
          enteredCode = ''; // Reset le code
        });
        startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Gap(20),
              Align(
                alignment: Alignment.topLeft,
                child: arrowBack(onTap: () => Navigator.pop(context)),
              ),

              // Icon container
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
                      Icons.message,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              const Gap(32),

              // Title
              const Text(
                'Vérifiez votre numéro',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const Gap(8),

              // Subtitle
              Text(
                'Entrez le code envoyé à ${widget.phoneNumber}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const Gap(40),

              // Code dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  bool isFilled = index < enteredCode.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
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

              const Gap(24),

              // Resend code text
              resendTimer > 0
                  ? RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondaryLight,
                      ),
                      children: [
                        const TextSpan(text: "Vous n'avez pas reçu de code ? "),
                        TextSpan(
                          text: '\nRenvoyer le code dans ${resendTimer}s',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                  : RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondaryLight,
                      ),
                      children: [
                        const TextSpan(text: "Vous n'avez pas reçu de code ? "),
                        TextSpan(
                          text: '\nRenvoyer le code',
                          style: TextStyle(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer:
                              TapGestureRecognizer()..onTap = resendCode,
                        ),
                      ],
                    ),
                  ),

              const Gap(32),

              // Verify button avec animation
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      enteredCode.length == 6 && !isVerifying
                          ? _startVerification
                          : () {
                            showCustomSnackBar(
                              context,
                              message: "Veuillez saisir le code",
                              isError: true,
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      isVerifying
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Vérifier',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),

              const Spacer(),

              // Custom Keypad
              _buildKeypad(),

              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('1'),
            _buildKeypadButton('2'),
            _buildKeypadButton('3'),
          ],
        ),

        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('4'),
            _buildKeypadButton('5'),
            _buildKeypadButton('6'),
          ],
        ),

        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKeypadButton('7'),
            _buildKeypadButton('8'),
            _buildKeypadButton('9'),
          ],
        ),

        // Row 4: empty, 0, backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70, height: 70), // Empty space
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
          color: Colors.transparent,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: const Center(
          child: Icon(Icons.backspace_outlined, size: 24, color: Colors.black),
        ),
      ),
    );
  }
}

// class VerifyNumberView extends StatefulWidget {
//   final String? phoneNumber;

//   static const String idView = "verifynumberview";

//   const VerifyNumberView({super.key, this.phoneNumber});

//   @override
//   State<VerifyNumberView> createState() => _VerifyNumberViewState();
// }

// class _VerifyNumberViewState extends State<VerifyNumberView> {
//   String enteredCode = '';
//   int resendTimer = 59;
//   Timer? timer;
//   bool isVerifying = false;

//   // Code de test pour simulation (à remplacer par votre vraie logique)
//   final String correctCode = '123456';

//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//   }

//   void startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (resendTimer > 0) {
//         setState(() {
//           resendTimer--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   void onNumberPressed(String number) {
//     if (enteredCode.length < 6 && !isVerifying) {
//       setState(() {
//         enteredCode += number;
//       });

//       // Si on a 6 chiffres, démarrer la vérification
//       if (enteredCode.length == 6) {
//         _startVerification();
//       }
//     }
//   }

//   void onBackspacePressed() {
//     if (enteredCode.isNotEmpty && !isVerifying) {
//       setState(() {
//         enteredCode = enteredCode.substring(0, enteredCode.length - 1);
//       });
//     }
//   }

//   void _startVerification() {
//     setState(() {
//       isVerifying = true;
//     });

//     // Simuler une vérification réseau (2 secondes)
//     Future.delayed(const Duration(seconds: 2), () {
//       if (enteredCode == correctCode) {
//         _showSuccessDialog();
//       } else {
//         _showErrorSnackBar();
//       }
//     });
//   }

//   void _showSuccessDialog() {
//     setState(() {
//       isVerifying = false;
//     });

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder:
//           (context) => AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             contentPadding: const EdgeInsets.all(24),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Icône de succès
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.green.withOpacity(0.1),
//                   ),
//                   child: const Icon(
//                     Icons.check_circle,
//                     color: Colors.green,
//                     size: 50,
//                   ),
//                 ),
//                 const Gap(20),
//                 const Text(
//                   'Numéro vérifié !',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const Gap(12),
//                 Text(
//                   'Votre numéro ${widget.phoneNumber} a été vérifié avec succès.',
//                   style: TextStyle(
//                     fontFamily: 'Poppins',
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: AppColors.textSecondaryLight,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const Gap(24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       navigateWithTransition(
//                         context: context,
//                         page: CreatePinView(),
//                         direction: TransitionDirection.rightToLeft,
//                         replace: true,
//                       );

//                       print('Navigation vers PIN View');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryLight,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Continuer',
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }

//   void _showErrorSnackBar() {
//     setState(() {
//       isVerifying = false;
//       enteredCode = ''; // Reset le code
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline, color: Colors.white),
//             const Gap(12),
//             const Text(
//               'Code incorrect. Veuillez réessayer.',
//               style: TextStyle(
//                 fontFamily: 'Poppins',
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void resendCode() {
//     if (resendTimer == 0) {
//       setState(() {
//         resendTimer = 59;
//         enteredCode = ''; // Reset le code
//       });
//       startTimer();
//       print('Code renvoyé');

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.send, color: Colors.white),
//               const Gap(12),
//               const Text(
//                 'Code renvoyé avec succès !',
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//           ),
//           margin: const EdgeInsets.all(16),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             children: [
//               const Gap(20),
//               Align(
//                 alignment: Alignment.topLeft,
//                 child: arrowBack(onTap: () => Navigator.pop(context)),
//               ),
//               // const Gap(60),

//               // Icon container
//               Container(
//                 height: 80,
//                 width: 80,
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(61, 0, 82, 204),
//                   borderRadius: BorderRadius.circular(40),
//                 ),
//                 child: Center(
//                   child: Container(
//                     height: 50,
//                     width: 50,
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryLight,
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: const Icon(
//                       Icons.message,
//                       // Icons.phone_android,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                 ),
//               ),

//               const Gap(32),

//               // Title
//               const Text(
//                 'Vérifiez votre numéro',
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 24,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const Gap(8),

//               // Subtitle
//               Text(
//                 'Entrez le code envoyé à ${widget.phoneNumber}',
//                 style: TextStyle(
//                   fontFamily: 'Poppins',
//                   fontSize: 14,
//                   fontWeight: FontWeight.w400,
//                   color: AppColors.textSecondaryLight,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               const Gap(40),

//               // Code dots indicator
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(6, (index) {
//                   bool isFilled = index < enteredCode.length;
//                   return Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 6),
//                     width: 16,
//                     height: 16,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color:
//                           isFilled
//                               ? AppColors.primaryLight
//                               : Colors.transparent,
//                       border: Border.all(
//                         color:
//                             isFilled
//                                 ? AppColors.primaryLight
//                                 : Colors.grey[300]!,
//                         width: 2,
//                       ),
//                     ),
//                   );
//                 }),
//               ),

//               const Gap(24),

//               // Resend code text
//               resendTimer > 0
//                   ? RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: AppColors.textSecondaryLight,
//                       ),
//                       children: [
//                         const TextSpan(text: "Vous n'avez pas reçu de code ? "),
//                         TextSpan(
//                           text: 'Renvoyer le code dans ${resendTimer}s',
//                           style: TextStyle(
//                             color: AppColors.primaryLight,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                   : RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       style: TextStyle(
//                         fontFamily: 'Poppins',
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: AppColors.textSecondaryLight,
//                       ),
//                       children: [
//                         const TextSpan(text: "Vous n'avez pas reçu de code ? "),
//                         TextSpan(
//                           text: 'Renvoyer le code',
//                           style: TextStyle(
//                             color: AppColors.primaryLight,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           recognizer:
//                               TapGestureRecognizer()..onTap = resendCode,
//                         ),
//                       ],
//                     ),
//                   ),

//               const Gap(32),

//               // Verify button avec animation
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed:
//                       enteredCode.length == 6 && !isVerifying
//                           ? _startVerification
//                           : () {
//                             showCustomSnackBar(
//                               context,
//                               message: "Veuillez saisir le code",
//                               isError: true,
//                             );
//                           },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primaryLight,

//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     elevation: 0,
//                   ),
//                   child:
//                       isVerifying
//                           ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 Colors.white,
//                               ),
//                             ),
//                           )
//                           : const Text(
//                             'Vérifier',
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                 ),
//               ),

//               const Spacer(),

//               // Custom Keypad
//               _buildKeypad(),

//               const Gap(40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildKeypad() {
//     return Column(
//       children: [
//         // Row 1: 1, 2, 3
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildKeypadButton('1'),
//             _buildKeypadButton('2'),
//             _buildKeypadButton('3'),
//           ],
//         ),
//         // const Gap(20),

//         // Row 2: 4, 5, 6
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildKeypadButton('4'),
//             _buildKeypadButton('5'),
//             _buildKeypadButton('6'),
//           ],
//         ),
//         // const Gap(20),

//         // Row 3: 7, 8, 9
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _buildKeypadButton('7'),
//             _buildKeypadButton('8'),
//             _buildKeypadButton('9'),
//           ],
//         ),
//         // const Gap(20),

//         // Row 4: empty, 0, backspace
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             const SizedBox(width: 70, height: 70), // Empty space
//             _buildKeypadButton('0'),
//             _buildBackspaceButton(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildKeypadButton(String number) {
//     return GestureDetector(
//       onTap: () => onNumberPressed(number),
//       child: Container(
//         width: 70,
//         height: 70,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.transparent,
//         ),
//         child: Center(
//           child: Text(
//             number,
//             style: const TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 24,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBackspaceButton() {
//     return GestureDetector(
//       onTap: onBackspacePressed,
//       child: Container(
//         width: 70,
//         height: 70,
//         decoration: const BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.transparent,
//         ),
//         child: const Center(
//           child: Icon(Icons.backspace_outlined, size: 24, color: Colors.black),
//         ),
//       ),
//     );
//   }
// }
