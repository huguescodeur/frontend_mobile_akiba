class UserModel {
  final int id;
  final String uuid;
  final String fullName;
  final String phoneNumber;
  final String? profilePicture;
  final bool isPhoneVerified;
  final bool hasPinCode;
  final DateTime dateJoined;

  UserModel({
    required this.id,
    required this.uuid,
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
      uuid: json['uuid'] ?? 0,
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
      'uuid': uuid,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'is_phone_verified': isPhoneVerified,
      'has_pin_code': hasPinCode,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  String get firstName {
    return fullName.split(' ').first;
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  bool get hasProfilePicture =>
      profilePicture != null && profilePicture!.isNotEmpty;

  UserModel copyWith({
    int? id,
    String? uuid,
    String? fullName,
    String? phoneNumber,
    String? profilePicture,
    bool? isPhoneVerified,
    bool? hasPinCode,
    DateTime? dateJoined,
  }) {
    return UserModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      hasPinCode: hasPinCode ?? this.hasPinCode,
      dateJoined: dateJoined ?? this.dateJoined,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, uuid: $uuid, fullName: $fullName, phoneNumber: $phoneNumber)';
  }
}
