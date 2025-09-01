import 'package:akiba/models/auth_models/user_model.dart';

class UserProfileResponseModel {
  final bool success;
  final UserModel user;
  final bool requiresPinSetup;
  final bool requiresPinAuth;

  UserProfileResponseModel({
    required this.success,
    required this.user,
    required this.requiresPinSetup,
    required this.requiresPinAuth,
  });

  factory UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UserProfileResponseModel(
      success: json['success'] ?? false,
      user: UserModel.fromJson(json['user'] ?? {}),
      requiresPinSetup: json['requires_pin_setup'] ?? false,
      requiresPinAuth: json['requires_pin_auth'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'user': user.toJson(),
      'requires_pin_setup': requiresPinSetup,
      'requires_pin_auth': requiresPinAuth,
    };
  }
}
