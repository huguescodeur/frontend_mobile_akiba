import 'package:akiba/models/api_response_model.dart';
import 'package:akiba/models/auth_models/user_model.dart';
import 'package:akiba/models/auth_tokens_model.dart';

class LoginResponseModel extends ApiResponseModel {
  final AuthTokensModel? tokens;
  final UserModel? user;
  final bool requiresPinSetup;
  final bool requiredPinAuth;

  LoginResponseModel({
    required super.success,
    required super.message,
    this.tokens,
    this.user,
    required this.requiresPinSetup,
    required this.requiredPinAuth,
    super.data,
    super.errors,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      tokens:
          json['tokens'] != null
              ? AuthTokensModel.fromJson(json['tokens'])
              : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      requiresPinSetup: json['requires_pin_setup'] ?? false,
      requiredPinAuth: json['requires_pin_auth'] ?? false,
      data: json['data'],
      errors: json['errors'],
    );
  }
}
