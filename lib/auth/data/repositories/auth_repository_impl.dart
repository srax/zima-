import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  Future<AuthResponseModel> login(String username, String password);
  Future<AuthResponseModel> register(String username, String password);
  Future<bool> verifyToken(String token);
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
}

/// Repository implementation that coordinates between remote and local data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<AuthResponseModel> login(String username, String password) async {
    try {
      // Call remote API
      final authResponse = await _remoteDataSource.login(username, password);

      // Save token and user data locally
      await _localDataSource.saveToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await _localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }
      if (authResponse.user != null) {
        await _localDataSource.saveUser(authResponse.user!);
      }

      return authResponse;
    } catch (e) {
      // Clear any partial data on error
      await _localDataSource.clearAll();
      rethrow;
    }
  }

  @override
  Future<AuthResponseModel> register(String username, String password) async {
    try {
      // Call remote API
      final authResponse = await _remoteDataSource.register(username, password);

      // Save token and user data locally
      await _localDataSource.saveToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await _localDataSource.saveRefreshToken(authResponse.refreshToken!);
      }
      if (authResponse.user != null) {
        await _localDataSource.saveUser(authResponse.user!);
      }

      return authResponse;
    } catch (e) {
      // Clear any partial data on error
      await _localDataSource.clearAll();
      rethrow;
    }
  }

  @override
  Future<bool> verifyToken(String token) async {
    try {
      return await _remoteDataSource.verifyToken(token);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // First try to get from local storage
      final localUser = await _localDataSource.getUser();
      if (localUser != null) {
        return localUser;
      }

      // If not in local storage, try to fetch from remote
      final token = await _localDataSource.getToken();
      if (token != null) {
        final remoteUser = await _remoteDataSource.getCurrentUser(token);
        await _localDataSource.saveUser(remoteUser);
        return remoteUser;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Call remote logout
      final token = await _localDataSource.getToken();
      if (token != null) {
        await _remoteDataSource.logout(token);
      }
    } catch (e) {
      // Continue with local cleanup even if remote logout fails
    } finally {
      // Always clear local data
      await _localDataSource.clearAll();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _localDataSource.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _localDataSource.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Refresh user data from remote
  Future<UserModel?> refreshUserData() async {
    try {
      final token = await _localDataSource.getToken();
      if (token == null) return null;

      final user = await _remoteDataSource.getCurrentUser(token);
      await _localDataSource.saveUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Clear all authentication data
  Future<void> clearAllData() async {
    try {
      await _localDataSource.clearAll();
    } catch (e) {
      // Log error but don't throw
    }
  }
}
