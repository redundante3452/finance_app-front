import 'package:finance_app/core/models/user_model.dart';
import 'package:finance_app/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  AuthService(this._apiClient, this._secureStorage);

  /// Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Register new user
  Future<AuthResponse> register(String name, String email, String password) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  /// Get current user info from backend
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  /// Logout - clear all stored auth data
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _userEmailKey);
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored user data (without API call)
  Future<UserModel?> getStoredUser() async {
    final userId = await _secureStorage.read(key: _userIdKey);
    final userName = await _secureStorage.read(key: _userNameKey);
    final userEmail = await _secureStorage.read(key: _userEmailKey);

    if (userId == null || userName == null || userEmail == null) {
      return null;
    }

    return UserModel(
      id: userId,
      name: userName,
      email: userEmail,
    );
  }

  /// Get stored userId
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Save authentication data to secure storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _secureStorage.write(key: _tokenKey, value: authResponse.token);
    await _secureStorage.write(key: _userIdKey, value: authResponse.user.id);
    await _secureStorage.write(key: _userNameKey, value: authResponse.user.name);
    await _secureStorage.write(key: _userEmailKey, value: authResponse.user.email);
  }
}

/// Response from login/register endpoints
class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
