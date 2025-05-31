class AuthTokensModel {
  final String accessToken;
  final String refreshToken;

  AuthTokensModel({required this.accessToken, required this.refreshToken});

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'access': accessToken, 'refresh': refreshToken};
  }
}
