import 'package:akiba/models/api_response_model.dart';
import 'package:akiba/models/auth_tokens_model.dart';

class VerifyPhoneResponseModel extends ApiResponseModel {
  final int? userId;
  final AuthTokensModel? tokens;
  final bool requiresPinSetup;

  VerifyPhoneResponseModel({
    required super.success,
    required super.message,
    this.userId,
    this.tokens,
    required this.requiresPinSetup,
    super.data,
    super.errors,
  });

  factory VerifyPhoneResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyPhoneResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userId: json['user_id'],
      tokens:
          json['tokens'] != null
              ? AuthTokensModel.fromJson(json['tokens'])
              : null,
      requiresPinSetup: json['requires_pin_setup'] ?? true,
      data: json['data'],
      errors: json['errors'],
    );
  }
}
