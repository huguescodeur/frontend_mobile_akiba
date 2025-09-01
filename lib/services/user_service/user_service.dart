import 'dart:developer';

import 'package:akiba/models/auth_models/user_profile_response_model.dart';
import 'package:akiba/services/api_service.dart';
import 'package:akiba/services/auth_service/auth_service.dart';

class UserService {
  final ApiService _apiService = ApiService();
  final authService = AuthService();

  // Récupérer le profil utilisateur
  Future<UserProfileResponseModel?> getUserProfile() async {
    try {
      final token = await authService.getAccessToken();
      log('🔍 Récupération du profil utilisateur...');
      if (token != null && !authService.isTokenExpired(token)) {
        try {
          final response = await _apiService.getUserProfile(token: token);
          log('✅ Profil utilisateur récupéré: $response');

          return UserProfileResponseModel.fromJson(response);
        } catch (e) {
          log('⚠️ Erreur update background time: $e (non critique)');
          // Ne pas échouer si updateBackgroundTime échoue
        }
      } else {
        log('⚠️ Token invalide - pas de update background time');
      }
    } catch (e) {
      log('❌ Erreur récupération profil: $e');
      return null;
    }
  }

  // Mettre à jour le profil utilisateur (pour plus tard)
  Future<bool> updateUserProfile({
    String? fullName,
    String? profilePicture,
  }) async {
    try {
      log('🔄 Mise à jour du profil utilisateur...');

      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (profilePicture != null) data['profile_picture'] = profilePicture;

      final response = await _apiService.put('/accounts/profile/', data);
      log('✅ Profil mis à jour: $response');

      return response['success'] ?? false;
    } catch (e) {
      log('❌ Erreur mise à jour profil: $e');
      return false;
    }
  }
}
