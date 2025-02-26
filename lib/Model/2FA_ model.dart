class TwoFactorAuthModel {
  final String qrCode;
  final String secret;
  final String otpauthUrl;
  final bool isEnabled;

  TwoFactorAuthModel({
    required this.qrCode,
    required this.secret,
    required this.otpauthUrl,
    required this.isEnabled,
  });

  factory TwoFactorAuthModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorAuthModel(
      qrCode: json['qr_code'] ?? '',
      secret: json['secret'] ?? '',
      otpauthUrl: json['otpauth_url'] ?? '',
      isEnabled: json['is_enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_code': qrCode,
      'secret': secret,
      'otpauth_url': otpauthUrl,
      'is_enabled': isEnabled,
    };
  }
}
