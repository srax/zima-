import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Local data source for authentication operations
/// Handles local storage of tokens and user data
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> removeUser();
  Future<void> clearAll();
  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _refreshTokenKey = 'refresh_token';

  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(_tokenKey, token);
    } catch (e) {
      throw AuthLocalException('Failed to save token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return _prefs.getString(_tokenKey);
    } catch (e) {
      throw AuthLocalException('Failed to get token: $e');
    }
  }

  @override
  Future<void> removeToken() async {
    try {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_refreshTokenKey);
    } catch (e) {
      throw AuthLocalException('Failed to remove token: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(_userKey, userJson);
    } catch (e) {
      throw AuthLocalException('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = _prefs.getString(_userKey);
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw AuthLocalException('Failed to get user: $e');
    }
  }

  @override
  Future<void> removeUser() async {
    try {
      await _prefs.remove(_userKey);
    } catch (e) {
      throw AuthLocalException('Failed to remove user: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_refreshTokenKey);
      await _prefs.remove(_userKey);
    } catch (e) {
      throw AuthLocalException('Failed to clear all auth data: $e');
    }
  }

  @override
  /// Save refresh token
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _prefs.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      throw AuthLocalException('Failed to save refresh token: $e');
    }
  }

  @override
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return _prefs.getString(_refreshTokenKey);
    } catch (e) {
      throw AuthLocalException('Failed to get refresh token: $e');
    }
  }

  @override
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Custom exception for local storage errors
class AuthLocalException implements Exception {
  final String message;

  const AuthLocalException(this.message);

  @override
  String toString() => 'AuthLocalException: $message';
}
