import 'dart:developer';

import 'package:akiba/constants/app_colors.dart';
import 'package:akiba/constants/images.dart';
import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/views/auth/register/register_view.dart';
import 'package:akiba/widgets/components/custom_button.dart';
import 'package:akiba/widgets/components/custom_text_field.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl_mobile_field/country_picker_dialog.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  static const String idView = "loginview";

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  String? mobileNumber;
  String? completeMobileNumber;
  String selectedCountryCode = "CI";

  bool isLoading = false;

  AuthService authService = AuthService();

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
    });

    try {
      await authService.login(
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
                            image: AssetImage(
                              Images.loginIcon,
                            ), // Vous pouvez utiliser une icône différente ou la même
                          ),
                        ),
                      ),
                      Gap(24),
                      const Text(
                        'Bon retour parmi nous !',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(12),
                      Text(
                        'Connectez-vous pour économiser, relever des défis et gérer votre argent facilement. ',
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
                // CustomTextField(
                //   hintText: "Entrez votre email",
                //   controller: emailController,
                // ),
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
                  hintText: "Mot de passe",
                  controller: passwordController,
                  isPassword: true,
                ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Mot de passe oublié?",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                      label: "Se connecter",
                      onPressed: _handleLogin,
                    ),
                Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Vous n'avez pas de compte ? "),
                    GestureDetector(
                      onTap: () {
                        navigateWithTransition(
                          context: context,
                          page: RegisterView(),
                          direction: TransitionDirection.rightToLeft,
                        );
                      },
                      child: Text(
                        "Inscrivez-vous ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
