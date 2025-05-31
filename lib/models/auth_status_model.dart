class AuthStatusModel {
  final bool isFirstTime;
  final bool isAuthenticated;
  final bool hasPinCode;
  final bool requiredPinAuth;

  AuthStatusModel({
    required this.isFirstTime,
    required this.isAuthenticated,
    required this.hasPinCode,
    required this.requiredPinAuth,
  });
}
