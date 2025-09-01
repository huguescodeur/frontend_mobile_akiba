// user_provider.dart
import 'package:akiba/models/auth_models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_view_model.dart';
import 'user_state.dart';

// Provider principal
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

// Providers dérivés
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(userProvider).user;
});

final userDisplayNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.fullName ?? 'Utilisateur';
});

final userFirstNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.firstName ?? 'Utilisateur';
});
