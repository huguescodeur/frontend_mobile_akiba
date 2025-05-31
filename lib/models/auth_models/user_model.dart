class UserModel {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String? profilePicture;
  final bool isPhoneVerified;
  final bool hasPinCode;
  final DateTime dateJoined;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.profilePicture,
    required this.isPhoneVerified,
    required this.hasPinCode,
    required this.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePicture: json['profile_picture'],
      isPhoneVerified: json['is_phone_verified'] ?? false,
      hasPinCode: json['has_pin_code'] ?? false,
      dateJoined: DateTime.parse(
        json['date_joined'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'is_phone_verified': isPhoneVerified,
      'has_pin_code': hasPinCode,
      'date_joined': dateJoined.toIso8601String(),
    };
  }
}
