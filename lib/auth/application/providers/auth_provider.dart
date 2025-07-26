import 'package:flutter/material.dart';
import '../auth_service.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _currentToken;
  String? get currentToken => _currentToken;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthProvider() {
    _checkAuthStatus();
  }

  /// Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _isAuthenticated = await _service.isAuthenticated();
      if (_isAuthenticated) {
        _currentUser = await _service.getCurrentUser();
      }
    } catch (e) {
      _error = 'Failed to check authentication status';
      print('Error checking auth status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.login(username, password);

      if (result.isSuccess) {
        _isAuthenticated = true;
        _currentToken = result.token;
        _currentUser = await _service.getCurrentUser();
        _error = null;
        return true;
      } else {
        _error = result.error;
        return false;
      }
    } catch (e) {
      _error = 'Login failed. Please try again.';
      print('Error during login: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register user
  Future<bool> register(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _service.register(username, password);

      if (result.isSuccess) {
        _isAuthenticated = true;
        _currentToken = result.token;
        _currentUser = await _service.getCurrentUser();
        _error = null;
        return true;
      } else {
        _error = result.error;
        return false;
      }
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      print('Error during registration: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.logout();
      _isAuthenticated = false;
      _currentToken = null;
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = 'Logout failed';
      print('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    try {
      _currentUser = await _service.getCurrentUser();
      notifyListeners();
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
