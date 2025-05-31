import 'package:akiba/models/api_response_model.dart';

class CreatePinResponseModel extends ApiResponseModel {
  final bool registrationComplete;

  CreatePinResponseModel({
    required super.success,
    required super.message,
    required this.registrationComplete,
    super.data,
    super.errors,
  });

  factory CreatePinResponseModel.fromJson(Map<String, dynamic> json) {
    return CreatePinResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      registrationComplete: json['registration_complete'] ?? false,
      data: json['data'],
      errors: json['errors'],
    );
  }
}
