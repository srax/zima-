import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Remote data source for authentication operations
/// Handles all API calls related to authentication
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String username, String password);
  Future<AuthResponseModel> register(String username, String password);
  Future<bool> verifyToken(String token);
  Future<UserModel> getCurrentUser(String token);
  Future<void> logout(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static const String _baseUrl = 'https://api.d-id.com';
  static const String _apiVersion = '/v1';

  final Dio _dio;

  AuthRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<AuthResponseModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_apiVersion/auth/login',
        data: {'username': username, 'password': password},
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  @override
  Future<AuthResponseModel> register(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_apiVersion/auth/register',
        data: {'username': username, 'password': password},
        options: Options(headers: _getHeaders()),
      );

      if (response.statusCode == 201) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  @override
  Future<bool> verifyToken(String token) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_apiVersion/auth/verify',
        options: Options(headers: _getHeaders(token: token)),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_apiVersion/auth/me',
        options: Options(headers: _getHeaders(token: token)),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  @override
  Future<void> logout(String token) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_apiVersion/auth/logout',
        options: Options(headers: _getHeaders(token: token)),
      );

      if (response.statusCode != 200) {
        throw _handleHttpError(response);
      }
    } catch (e) {
      throw _handleNetworkError(e);
    }
  }

  Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Exception _handleHttpError(Response response) {
    final statusCode = response.statusCode;
    final body = response.data;

    switch (statusCode) {
      case 401:
        return AuthException('Invalid credentials');
      case 409:
        return AuthException('Username already exists');
      case 422:
        return AuthException('Invalid input data');
      case 500:
        return AuthException('Server error');
      default:
        return AuthException('HTTP Error $statusCode: $body');
    }
  }

  Exception _handleNetworkError(dynamic error) {
    if (error is AuthException) {
      return error;
    }
    return AuthException('Network error: ${error.toString()}');
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
