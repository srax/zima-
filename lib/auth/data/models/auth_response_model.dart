import 'user_model.dart';

/// Data model for authentication response from API
class AuthResponseModel {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserModel? user;

  const AuthResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
    this.user,
  });

  /// Create AuthResponseModel from JSON
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int? ?? 3600,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert AuthResponseModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      if (user != null) 'user': user!.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponseModel &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.tokenType == tokenType;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^ refreshToken.hashCode ^ tokenType.hashCode;
  }

  @override
  String toString() {
    return 'AuthResponseModel(accessToken: $accessToken, tokenType: $tokenType)';
  }
}
