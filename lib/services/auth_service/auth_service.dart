// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:akiba/enum/transition_direction.dart';
import 'package:akiba/models/api_response_model.dart';
import 'package:akiba/models/auth_models/create_pin_response_model.dart';
import 'package:akiba/models/auth_models/login_response_model.dart';
import 'package:akiba/models/auth_models/register_response_model.dart';
import 'package:akiba/models/auth_models/verify_phone_response.dart';
import 'package:akiba/models/auth_status_model.dart';
import 'package:akiba/models/auth_tokens_model.dart';
import 'package:akiba/services/api_service.dart';
import 'package:akiba/services/user_service/user_service.dart';
import 'package:akiba/views/auth/register/verify_number_view.dart';
import 'package:akiba/views/home/accueil_view.dart';
import 'package:akiba/views/home/verify_pin_view.dart';
import 'package:akiba/widgets/components/show_custom_snack_bar.dart';
import 'package:akiba/widgets/navigation/navigate_with_transition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final storage = FlutterSecureStorage();

  // ? Validation du numéro de téléphone (gardez votre logique existante)
  Future<bool> checkValidatePhoneNumber({
    required String phoneNumber,
    required String countryCode,
  }) async {
    try {
      final isoCode = IsoCode.values.firstWhere(
        (e) => e.name == countryCode,
        orElse: () => IsoCode.CI,
      );

      final phone = PhoneNumber.parse(phoneNumber, destinationCountry: isoCode);
      return phone.isValid(type: PhoneNumberType.mobile);
    } catch (e) {
      log('Error validating phone number: $e');
      return false;
    }
  }

  // ? === ÉTAPE 1: INSCRIPTION INITIALE ===
  Future<void> register({
    required String completeName,
    required String completeMobileNumber,
    required String selectedCountryCode,
    required String password,
    required BuildContext context,
  }) async {
    // Validation locale
    if (completeName.isEmpty ||
        completeMobileNumber.isEmpty ||
        password.isEmpty) {
      showCustomSnackBar(
        context,
        message: "Merci de remplir tous les champs avant de continuer.",
        isError: true,
      );
      return;
    }

    // Validation du numéro
    bool isValid = await checkValidatePhoneNumber(
      phoneNumber: completeMobileNumber,
      countryCode: selectedCountryCode,
    );

    if (!isValid) {
      showCustomSnackBar(
        context,
        message: "Numéro de téléphone invalide pour ce pays",
        isError: true,
      );
      return;
    }

    try {
      // ? Appel à l'API Django
      final response = await _apiService.register(
        fullName: completeName,
        phoneNumber: completeMobileNumber,
        password: password,
      );

      final registerResponse = RegisterResponseModel.fromJson(response);

      if (registerResponse.success) {
        // SMS envoyé avec succès
        showCustomSnackBar(
          context,
          message: registerResponse.message,
          isError: false,
        );

        // Navigation vers la page de vérification
        navigateWithTransition(
          context: context,
          page: VerifyNumberView(phoneNumber: completeMobileNumber),
          direction: TransitionDirection.leftToRight,
        );
      } else {
        // Erreur côté serveur
        showCustomSnackBar(
          context,
          message: registerResponse.message,
          isError: true,
        );
      }
    } catch (e) {
      log('Registration error: $e');
      showCustomSnackBar(context, message: e.toString(), isError: true);
    }
  }

  // ? === ÉTAPE 2: VÉRIFICATION DU CODE SMS ===
  Future<bool> verifyPhoneNumber({
    required String phoneNumber,
    required String verificationCode,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final response = await _apiService.verifyPhone(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
      );

      final verifyResponse = VerifyPhoneResponseModel.fromJson(response);

      if (verifyResponse.success && verifyResponse.tokens != null) {
        log('✅ Vérification réussie, tokens reçus');
        log('Access Token: ${verifyResponse.tokens!.accessToken}');

        // Sauvegarder les tokens JWT
        await _saveTokens(verifyResponse.tokens!);

        // VÉRIFICATION : Relire immédiatement après sauvegarde
        final savedTokens = await getSavedTokens();
        if (savedTokens != null) {
          log('✅ Tokens sauvegardés avec succès');
          log('Access Token sauvegardé: ${savedTokens.accessToken}');
        } else {
          log('❌ ERREUR: Tokens non sauvegardés !');
        }

        // Configurer l'en-tête d'autorisation
        _apiService.setAuthToken(verifyResponse.tokens!.accessToken);

        // try {
        //   await ref.read(userProvider.notifier).loadUserProfile();
        //   log('✅ Profil chargé dans le provider après vérify phone');
        // } catch (e) {
        //   log(
        //     '⚠️ Erreur chargement profil dans provider après vérify phone: $e',
        //   );
        // }

        return true;
      } else {
        showCustomSnackBar(
          context,
          message: verifyResponse.message,
          isError: true,
        );
        return false;
      }
    } catch (e) {
      log('Phone verification error: $e');
      showCustomSnackBar(context, message: e.toString(), isError: true);
      return false;
    }
  }

  // ? === ÉTAPE 3: CRÉATION DU CODE PIN ===
  Future<bool> createPin({
    required String pinCode,
    required String confirmPinCode,
    required BuildContext context,
  }) async {
    if (pinCode != confirmPinCode) {
      showCustomSnackBar(
        context,
        message: "Les codes PIN ne correspondent pas",
        isError: true,
      );
      return false;
    }

    if (pinCode.length != 5 || !pinCode.contains(RegExp(r'^\d+$'))) {
      showCustomSnackBar(
        context,
        message: "Le code PIN doit contenir exactement 5 chiffres",
        isError: true,
      );
      return false;
    }

    try {
      final token = await getAccessToken();
      _apiService.setAuthToken(token!);

      final response = await _apiService.createPin(
        pinCode: pinCode,
        confirmPinCode: confirmPinCode,
      );

      final createPinResponse = CreatePinResponseModel.fromJson(response);

      if (createPinResponse.success) {
        showCustomSnackBar(
          context,
          message: createPinResponse.message,
          isError: false,
        );
        return true;
      } else {
        showCustomSnackBar(
          context,
          message: createPinResponse.message,
          isError: true,
        );
        return false;
      }
    } catch (e) {
      log('Create PIN error: $e');
      showCustomSnackBar(context, message: e.toString(), isError: true);
      return false;
    }
  }

  // ? === VÉRIFICATION DU CODE PIN ===
  Future<bool> verifyPin({
    required String pinCode,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final token = await getAccessToken();
      _apiService.setAuthToken(token!);

      final response = await _apiService.verifyPin(pinCode: pinCode);
      final apiResponse = ApiResponseModel.fromJson(response);

      if (apiResponse.success) {
        // try {
        //   await ref.read(userProvider.notifier).loadUserProfile();
        //   log('✅ Profil chargé dans le provider après vérify pin');
        // } catch (e) {
        //   log('⚠️ Erreur chargement profil dans provider après vérify pin: $e');
        // }
        return true;
      } else {
        showCustomSnackBar(
          context,
          message: apiResponse.message,
          isError: true,
        );
        return false;
      }
    } catch (e) {
      log('PIN verification error: $e');
      showCustomSnackBar(context, message: e.toString(), isError: true);
      return false;
    }
  }

  // ? === RENVOYER LE CODE ===
  Future<bool> resendVerificationCode({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    try {
      final response = await _apiService.resendCode(phoneNumber: phoneNumber);
      final apiResponse = ApiResponseModel.fromJson(response);

      if (apiResponse.success) {
        showCustomSnackBar(
          context,
          message: apiResponse.message,
          isError: false,
        );
        return true;
      } else {
        showCustomSnackBar(
          context,
          message: apiResponse.message,
          isError: true,
        );
        return false;
      }
    } catch (e) {
      log('Resend code error: $e');
      showCustomSnackBar(context, message: e.toString(), isError: true);
      return false;
    }
  }

  // ? === CONNEXION ===
  Future<LoginResponseModel?> login({
    required String completeMobileNumber,
    required String password,
    required String selectedCountryCode,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    if (completeMobileNumber.isEmpty || password.isEmpty) {
      showCustomSnackBar(
        context,
        message: "Merci de remplir tous les champs avant de continuer.",
        isError: true,
      );
      return null;
    }

    // Validation du numéro
    bool isValid = await checkValidatePhoneNumber(
      phoneNumber: completeMobileNumber,
      countryCode: selectedCountryCode,
    );

    if (!isValid) {
      showCustomSnackBar(
        context,
        message: "Numéro de téléphone invalide pour ce pays",
        isError: true,
      );
      return null;
    }

    try {
      log("Début Login Lancement");
      final response = await _apiService.login(
        phoneNumber: completeMobileNumber,
        password: password,
      );

      final loginResponse = LoginResponseModel.fromJson(response);

      if (loginResponse.success && loginResponse.tokens != null) {
        // Sauvegarder les tokens
        await _saveTokens(loginResponse.tokens!);
        _apiService.setAuthToken(loginResponse.tokens!.accessToken);

        log("Login Response: $loginResponse");

        // try {
        //   await ref.read(userProvider.notifier).loadUserProfile();
        //   log('✅ Profil chargé dans le provider après connexion');
        // } catch (e) {
        //   log('⚠️ Erreur chargement profil dans provider: $e');
        // }

        navigateWithTransition(
          // page: const AccueilView(),
          context: context,
          page: VerifyPinView(),
          direction: TransitionDirection.rightToLeft,
          replace: true,
        );

        return loginResponse;
      } else {
        showCustomSnackBar(
          context,
          message: loginResponse.message,
          isError: true,
        );
        return null;
      }
    } catch (e) {
      log('Login error: $e');
      showCustomSnackBar(context, message: e.toString(), isError: true);
      return null;
    }
  }

  // ? === GESTION DES TOKENS JWT ===
  // ⭐ Flag pour éviter les appels récursifs
  bool isRefreshing = false;
  Future<void> _saveTokens(AuthTokensModel tokens) async {
    try {
      await storage.write(key: 'access_token', value: tokens.accessToken);
      await storage.write(key: 'refresh_token', value: tokens.refreshToken);
      log('✅ Tokens écrits dans le storage');

      // Vérification immédiate
      final readAccess = await storage.read(key: 'access_token');
      final readRefresh = await storage.read(key: 'refresh_token');

      if (readAccess != null && readRefresh != null) {
        log('✅ Vérification lecture storage OK');
      } else {
        log('❌ ERREUR: Impossible de relire les tokens du storage');
      }
    } catch (e) {
      log('❌ ERREUR sauvegarde tokens: $e');
    }
  }

  Future<AuthTokensModel?> getSavedTokens() async {
    try {
      final accessToken = await storage.read(key: 'access_token');
      final refreshToken = await storage.read(key: 'refresh_token');

      log("accessToken: $accessToken");
      log("refreshToken: $refreshToken");

      if (accessToken != null && refreshToken != null) {
        return AuthTokensModel(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      return null;
    } catch (e) {
      log('❌ Erreur getSavedTokens: $e');
      return null;
    }
  }

  bool isTokenExpired(String token) {
    try {
      if (token.isEmpty || token.split('.').length != 3) {
        log('❌ Token mal formé');
        return true;
      }

      final expiryDate = Jwt.getExpiryDate(token);
      if (expiryDate == null) {
        log('❌ Impossible de récupérer la date d\'expiration');
        return true;
      }

      // Marge de 30 secondes pour éviter les requêtes avec un token sur le point d'expirer
      final now = DateTime.now().add(const Duration(seconds: 30));
      final isExpired = expiryDate.isBefore(now);

      log('Token expiré ? $isExpired (expire: $expiryDate, now: $now)');
      return isExpired;
    } catch (e) {
      log('❌ Erreur vérification expiration: $e');
      return true; // En cas d'erreur, considérer comme expiré
    }
  }

  Future<void> clearTokens() async {
    try {
      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
      _apiService.clearAuthToken();
      log('✅ Tokens supprimés');
    } catch (e) {
      log('❌ Erreur clearTokens: $e');
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: 'access_token');
    } catch (e) {
      log('❌ Erreur getAccessToken: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await storage.read(key: 'refresh_token');
    } catch (e) {
      log('❌ Erreur getRefreshToken: $e');
      return null;
    }
  }

  Future<bool> refreshAuthToken() async {
    if (isRefreshing) {
      log('⚠️ Refresh déjà en cours, abandon');
      return false;
    }

    isRefreshing = true;

    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log("❌ Aucun refresh token. L'utilisateur doit se reconnecter.");
        return false;
      }

      if (isTokenExpired(refreshToken)) {
        log("❌ Refresh token expiré. L'utilisateur doit se reconnecter.");
        await clearTokens();
        return false;
      }

      log('🔄 Tentative de refresh du token...');

      final refreshDio = Dio();
      refreshDio.options = BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final response = await refreshDio.post(
        '/accounts/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'];
      final newRefreshToken = response.data['refresh'];

      log("New Access Token: $newAccessToken");
      log("New Refresh Token : $newRefreshToken");

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await storage.write(key: 'access_token', value: newAccessToken);

        // ✅ Si un nouveau refresh token est envoyé, on le met à jour
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await storage.write(key: 'refresh_token', value: newRefreshToken);
          log('🔁 Nouveau refresh token sauvegardé');
        }

        _apiService.setAuthToken(newAccessToken);
        log("✅ Token renouvelé avec succès !");
        return true;
      } else {
        log("❌ Réponse invalide lors du refresh");
        await clearTokens();
        return false;
      }
    } catch (e) {
      log("❌ Erreur lors du rafraîchissement du token: $e");
      if (e is DioException && e.response?.statusCode == 401) {
        log("❌ Refresh token blacklisté ou invalide - déconnexion forcée");
        await clearTokens();
      }
      return false;
    } finally {
      isRefreshing = false;
    }
  }

  void checkTokenExpiry(String token) {
    try {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      DateTime? expiryDate = Jwt.getExpiryDate(token);
      DateTime now = DateTime.now();

      log("=== TOKEN INFO ===");
      log("Payload: $payload");
      if (expiryDate != null) {
        log('Expire à: $expiryDate');
        log('Maintenant: $now');
        log('Temps restant: ${expiryDate.difference(now).inMinutes} minutes');
        log('Est expiré ? ${expiryDate.isBefore(now)}');
      } else {
        log('⚠️ Impossible de déterminer la date d\'expiration');
      }
      log("==================");
    } catch (e) {
      log('Erreur analyse token: $e');
    }
  }

  // ⭐ Version simplifiée de isLoggedIn sans récursion
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await getAccessToken();

      // Pas de token du tout
      if (accessToken == null || accessToken.isEmpty) {
        log('❌ Pas d\'access token');
        return false;
      }

      // Si l'access token est valide, on est connecté
      if (!isTokenExpired(accessToken)) {
        _apiService.setAuthToken(accessToken);
        log('✅ Access token valide');
        return true;
      }

      log('⚠️ Access token expiré');
      return false;
    } catch (e) {
      log('❌ Erreur dans isLoggedIn: $e');
      return false;
    }
  }

  Future<void> logout() async {
    log("Déconnecté");
    await clearTokens();
  }

  Future<AuthStatusModel> checkAuthStatus({bool forceRefresh = false}) async {
    log('🔍 Début vérification statut auth');

    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService();

      await authService.debugStorage();

      final isFirstTime = prefs.getBool('is_first_time') ?? true;
      log('isFirstTime: $isFirstTime');

      // ⭐ Récupération simple des tokens
      final accessToken = await authService.getAccessToken();
      final refreshToken = await authService.getRefreshToken();

      // ⭐ Si pas de tokens du tout
      if (accessToken == null || refreshToken == null) {
        log('❌ Pas de tokens - pas connecté');
        return AuthStatusModel(
          isFirstTime: isFirstTime,
          isAuthenticated: false,
          hasPinCode: false,
          requiredPinAuth: false,
        );
      }

      // ⭐ Vérifier et gérer l'expiration des tokens
      String? validToken = accessToken;

      if (authService.isTokenExpired(accessToken)) {
        log('⚠️ Access token expiré');

        // Vérifier le refresh token
        if (authService.isTokenExpired(refreshToken)) {
          log('❌ Refresh token aussi expiré');
          await authService.clearTokens();
          return AuthStatusModel(
            isFirstTime: isFirstTime,
            isAuthenticated: false,
            hasPinCode: false,
            requiredPinAuth: false,
          );
        }

        // ⭐ Tenter le refresh UNE SEULE FOIS
        log('🔄 Tentative de refresh du token');
        final refreshSuccess = await refreshAuthToken();

        if (!refreshSuccess) {
          log('❌ Échec du refresh');
          await authService.clearTokens();
          return AuthStatusModel(
            isFirstTime: isFirstTime,
            isAuthenticated: false,
            hasPinCode: false,
            requiredPinAuth: false,
          );
        }

        // Récupérer le nouveau token
        validToken = await authService.getAccessToken();
        if (validToken == null) {
          log('❌ Token null après refresh');
          return AuthStatusModel(
            isFirstTime: isFirstTime,
            isAuthenticated: false,
            hasPinCode: false,
            requiredPinAuth: false,
          );
        }
      }

      // ⭐ Appel API avec le token valide
      log('✅ Token valide, appel API auth-status');

      // ⭐ Timeout pour éviter les blocages
      final apiService = ApiService();
      final response = await apiService
          .getAuthStatus(token: validToken!)
          .timeout(const Duration(seconds: 10));

      log("✅ Response Auth-Status: $response");

      return AuthStatusModel(
        isFirstTime: false,
        isAuthenticated: true,
        hasPinCode: response['has_pin_code'] ?? false,
        requiredPinAuth: response['requires_pin_auth'] ?? false,
      );
    } on TimeoutException {
      log('❌ Timeout lors de l\'appel API');
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('is_first_time') ?? true;
      return AuthStatusModel(
        isFirstTime: isFirstTime,
        isAuthenticated: false,
        hasPinCode: false,
        requiredPinAuth: false,
      );
    } catch (e) {
      log('❌ Erreur dans _checkAuthStatus: $e');
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('is_first_time') ?? true;

      return AuthStatusModel(
        isFirstTime: isFirstTime,
        isAuthenticated: false,
        hasPinCode: false,
        requiredPinAuth: false,
      );
    }
  }

  tokenExist() async {
    final loggedIn = await isLoggedIn();

    if (!loggedIn) {
      // Vérifier pourquoi - tokens expirés ? Pas de tokens ?
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();

      log('Access token: ${accessToken != null ? "Présent" : "Absent"}');
      log('Refresh token: ${refreshToken != null ? "Présent" : "Absent"}');

      if (accessToken != null) {
        log('Access expired: ${isTokenExpired(accessToken)}');
      }
      if (refreshToken != null) {
        log('Refresh expired: ${isTokenExpired(refreshToken)}');
      }
    }
  }

  Future<void> loadUserProfileAfterAuth() async {
    try {
      // Cette méthode sera appelée après une connexion réussie
      // pour charger immédiatement le profil utilisateur
      log('🔄 Chargement du profil après authentification...');

      final userService = UserService();
      final profileResponse = await userService.getUserProfile();

      if (profileResponse != null && profileResponse.success) {
        log('✅ Profil chargé après auth: ${profileResponse.user.fullName}');
        // Vous pouvez déclencher un événement ou utiliser un callback ici
      }
    } catch (e) {
      log('❌ Erreur chargement profil après auth: $e');
    }
  }

  Future<void> debugStorage() async {
    try {
      final accessToken = await storage.read(key: 'access_token');
      final refreshToken = await storage.read(key: 'refresh_token');

      log('=== DEBUG STORAGE ===');
      log(
        'Access Token: ${accessToken != null ? 'Présent (${accessToken.length} chars)' : 'ABSENT'}',
      );
      log(
        'Refresh Token: ${refreshToken != null ? 'Présent (${refreshToken.length} chars)' : 'ABSENT'}',
      );

      if (accessToken != null) {
        log('Access token expiré ? ${isTokenExpired(accessToken)}');
      }
      if (refreshToken != null) {
        log('Refresh token expiré ? ${isTokenExpired(refreshToken)}');
      }

      log('=====================');
    } catch (e) {
      log('❌ Erreur debug storage: $e');
    }
  }
}
