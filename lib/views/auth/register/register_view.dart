// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/constants/images.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/views/auth/login/login_view.dart';
import 'package:akiba/widgets/components/custom_button.dart';
import 'package:akiba/widgets/components/custom_text_field.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl_mobile_field/country_picker_dialog.dart';

import 'package:intl_mobile_field/intl_mobile_field.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  static const String idView = "registerview";

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? mobileNumber;
  String? completeMobileNumber;
  String selectedCountryCode = "CI";

  // État de chargement
  bool isLoading = false;

  AuthService authService = AuthService();

  // Méthode pour gérer l'inscription avec loading
  Future<void> _handleRegister() async {
    setState(() {
      isLoading = true;
    });

    try {
      await authService.register(
        completeName: nameController.text,
        completeMobileNumber: completeMobileNumber ?? '',
        selectedCountryCode: selectedCountryCode,
        password: passwordController.text,
        context: context,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(60),
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 78,
                        width: 78,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLightGray,
                          borderRadius: BorderRadius.circular(50),
                          image: DecorationImage(
                            image: AssetImage(Images.signUpIcon),
                          ),
                        ),
                      ),
                      Gap(24),
                      const Text(
                        'Inscrivez-vous et créez votre compte !',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(12),
                      Text(
                        "Rejoignez-nous pour une gestion d'argent simple, ludique et sécurisée.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  hintText: 'Nom complet',
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                IntlMobileField(
                  cursorColor: AppColors.primaryLight,
                  pickerDialogStyle: PickerDialogStyle(
                    shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    searchFieldInputDecoration: InputDecoration(
                      hintText: "Rechercher un pays...",
                    ),
                  ),
                  fillColor: AppColors.backgroundLightGray,
                  initialCountryCode: "CI",
                  onCountryChanged: (country) {
                    setState(() {
                      selectedCountryCode = country.code;
                    });
                    log('Country Dial Code: ${country.dialCode}');
                    log('Country Code: ${country.code}');
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.deny(RegExp(r'\s|\+')),
                  ],
                  decoration: InputDecoration(
                    hintText: "Numéro de téléphone",
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  invalidNumberMessage: "Veuillez entrer un numéro valide",
                  onChanged: (number) {
                    setState(() {
                      mobileNumber = number.number;
                      completeMobileNumber =
                          "${number.countryCode}${number.number}";
                    });
                    log("Changed: $mobileNumber");
                    log("Complete Changed: $completeMobileNumber");
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  hintText: 'Mot de passe',
                  isPassword: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 32),

                // Bouton avec état de chargement
                isLoading
                    ? SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                    )
                    : CustomButton(
                      label: "Créer un compte",
                      onPressed: _handleRegister,
                    ),

                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      navigateWithTransition(
                        context: context,
                        page: LoginView(),
                        direction: TransitionDirection.leftToRight,
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Vous avez déjà un compte ? ",
                        children: [
                          TextSpan(
                            text: "Connectez-vous",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
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
}

// class RegisterView extends ConsumerStatefulWidget {
//   const RegisterView({super.key});

//   static const String idView = "registerview";

//   @override
//   ConsumerState<RegisterView> createState() => _RegisterViewState();
// }

// class _RegisterViewState extends ConsumerState<RegisterView> {
//   final TextEditingController nameController = TextEditingController();

//   final TextEditingController passwordController = TextEditingController();

//   String? mobileNumber;
//   String? completeMobileNumber;
//   String selectedCountryCode = "CI";

//   AuthService authService = AuthService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Gap(60),
//                 Center(
//                   child: Column(
//                     children: [
//                       Container(
//                         height: 78,
//                         width: 78,

//                         decoration: BoxDecoration(
//                           color: AppColors.backgroundLightGray,
//                           borderRadius: BorderRadius.circular(50),
//                           image: DecorationImage(
//                             image: AssetImage(Images.signUpIcon),
//                           ),
//                         ),
//                       ),

//                       Gap(24),
//                       const Text(
//                         'Inscrivez-vous et créez votre compte !',
//                         style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 20,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       Gap(12),
//                       Text(
//                         'Rejoignez-nous pour une gestion d’argent simple, ludique et sécurisée.',
//                         style: TextStyle(
//                           fontFamily: 'Poppins',
//                           fontSize: 12,
//                           color: AppColors.textSecondaryLight,
//                           fontWeight: FontWeight.w300,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 CustomTextField(
//                   hintText: 'Nom complet',
//                   controller: nameController,
//                 ),
//                 const SizedBox(height: 16),

//                 IntlMobileField(
//                   cursorColor: AppColors.primaryLight,

//                   pickerDialogStyle: PickerDialogStyle(
//                     shape: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     searchFieldInputDecoration: InputDecoration(
//                       hintText: "Rechercher un pays...",
//                       // border: OutlineInputBorder(),
//                     ),
//                   ),
//                   fillColor: AppColors.backgroundLightGray,
//                   initialCountryCode: "CI",
//                   onCountryChanged: (country) {
//                     setState(() {
//                       selectedCountryCode = country.code;
//                     });
//                     log('Country Dial Code: ${country.dialCode}');
//                     log('Country Code: ${country.code}');
//                   },
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     FilteringTextInputFormatter.deny(RegExp(r'\s|\+')),
//                   ],
//                   decoration: InputDecoration(
//                     hintText: "Numéro de téléphone",
//                     border: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   invalidNumberMessage: "Enter a Valid Number",
//                   onChanged: (number) {
//                     setState(() {
//                       // String dialCode = number.countryCode.replaceAll('+', '');
//                       // completeMobileNumber = dialCode + number.number;
//                       mobileNumber = number.number;

//                       completeMobileNumber =
//                           "${number.countryCode}${number.number}";
//                     });
//                     log("Changed: $mobileNumber");
//                     log("Complete Changed: $completeMobileNumber");
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 CustomTextField(
//                   hintText: 'Mot de passe',
//                   isPassword: true,
//                   controller: passwordController,
//                 ),
//                 const SizedBox(height: 32),

//                 CustomButton(
//                   label: "Créer un compte",
//                   onPressed: () {
//                     log("Mobile Number: $mobileNumber");
//                     log("Selected Country Code: $selectedCountryCode");
//                     authService.register(
//                       completeName: nameController.text,
//                       completeMobileNumber: completeMobileNumber ?? '',
//                       selectedCountryCode: selectedCountryCode,
//                       password: passwordController.text,
//                       context: context,
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Center(
//                   child: GestureDetector(
//                     onTap: () {
//                       navigateWithTransition(
//                         context: context,
//                         page: LoginView(),
//                         direction: TransitionDirection.leftToRight,
//                       );
//                     },
//                     child: const Text.rich(
//                       TextSpan(
//                         text: "Vous avez déjà un compte ? ",
//                         children: [
//                           TextSpan(
//                             text: "Connectez-vous",
//                             style: TextStyle(
//                               fontFamily: 'Poppins',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.primaryLight,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
