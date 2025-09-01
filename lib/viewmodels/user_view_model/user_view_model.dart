// user_view_model.dart
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akiba/models/auth_models/user_model.dart';
import 'package:akiba/services/auth_service/auth_service.dart';
import 'package:akiba/services/user_service/user_service.dart';
import 'user_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  UserNotifier() : super(UserState());

  Future<void> loadUserProfile() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        state = state.copyWith(
          isLoading: false,
          error: 'Utilisateur non connecté',
        );
        return;
      }
      final profileResponse = await _userService.getUserProfile();
      if (profileResponse != null && profileResponse.success) {
        state = state.copyWith(
          user: profileResponse.user,
          isLoading: false,
          error: null,
        );
        log('✅ Profil utilisateur chargé: ${profileResponse.user.fullName}');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Impossible de récupérer le profil utilisateur',
        );
      }
    } catch (e) {
      log('❌ Erreur chargement profil: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({String? fullName, String? profilePicture}) async {
    if (state.user == null) return false;
    try {
      final success = await _userService.updateUserProfile(
        fullName: fullName,
        profilePicture: profilePicture,
      );
      if (success) {
        await loadUserProfile();
        return true;
      }
      return false;
    } catch (e) {
      log('❌ Erreur mise à jour profil: $e');
      return false;
    }
  }

  void clearUser() {
    state = UserState();
    log('🧹 Données utilisateur nettoyées');
  }

  // Getters utiles
  bool get isUserLoaded => state.user != null;
}

// UserModel? get currentUser => state.user;
// String get displayName => state.user?.fullName ?? 'Utilisateur';
// String get firstName => state.user?.firstName ?? 'Utilisateur';
