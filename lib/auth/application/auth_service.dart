import '../data/repositories/auth_repository_impl.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/auth_local_data_source.dart';
import '../data/models/auth_response_model.dart';
import '../data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Business logic service for authentication
/// Handles login, registration, and token management
class AuthService {
  late final AuthRepository _repository;

  AuthService() {
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalDataSourceImpl(prefs);
    final remoteDataSource = AuthRemoteDataSourceImpl();
    _repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
  }

  /// Authenticate user with username and password
  Future<AuthResult> login(String username, String password) async {
    try {
      // Validate input
      if (username.trim().isEmpty || password.isEmpty) {
        return AuthResult.failure('Please enter both username and password');
      }

      // Wait for repository initialization
      await _ensureRepositoryInitialized();

      // Attempt login
      final authResponse = await _repository.login(username.trim(), password);

      return AuthResult.success(authResponse.accessToken);
    } catch (e) {
      return AuthResult.failure(_handleAuthError(e));
    }
  }

  /// Register new user
  Future<AuthResult> register(String username, String password) async {
    try {
      // Validate input
      if (username.trim().isEmpty || password.isEmpty) {
        return AuthResult.failure('Please enter both username and password');
      }

      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters');
      }

      // Wait for repository initialization
      await _ensureRepositoryInitialized();

      // Attempt registration
      final authResponse = await _repository.register(
        username.trim(),
        password,
      );

      return AuthResult.success(authResponse.accessToken);
    } catch (e) {
      return AuthResult.failure(_handleAuthError(e));
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      await _ensureRepositoryInitialized();
      return await _repository.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _ensureRepositoryInitialized();
      await _repository.logout();
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      await _ensureRepositoryInitialized();
      return await _repository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  /// Ensure repository is initialized
  Future<void> _ensureRepositoryInitialized() async {
    // Repository is initialized in constructor, but we ensure it's ready
    if (!_repository.toString().contains('AuthRepositoryImpl')) {
      await _initializeRepository();
    }
  }

  /// Handle authentication errors
  String _handleAuthError(dynamic error) {
    if (error.toString().contains('401')) {
      return 'Invalid username or password';
    } else if (error.toString().contains('409')) {
      return 'Username already exists';
    } else if (error.toString().contains('network')) {
      return 'Network error. Please check your connection';
    } else {
      return 'Authentication failed. Please try again';
    }
  }
}

/// Result of authentication operations
class AuthResult {
  final bool isSuccess;
  final String? token;
  final String? error;

  AuthResult._({required this.isSuccess, this.token, this.error});

  factory AuthResult.success(String token) {
    return AuthResult._(isSuccess: true, token: token);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}
