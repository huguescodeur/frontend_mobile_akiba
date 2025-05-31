import 'package:akiba/models/api_response_model.dart';

class RegisterResponseModel extends ApiResponseModel {
  final String? phoneNumber;

  RegisterResponseModel({
    required super.success,
    required super.message,
    this.phoneNumber,
    super.data,
    super.errors,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      phoneNumber: json['phone_number'],
      data: json['data'],
      errors: json['errors'],
    );
  }
}
