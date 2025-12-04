import 'package:finance_app/core/models/user_model.dart';
import 'package:finance_app/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  UserService(this._apiClient, this._secureStorage);

  /// Get current user ID from storage
  Future<String?> _getUserId() async {
    String? userId = await _secureStorage.read(key: 'user_id');
    
    // If userId is not in storage, fetch from API
    if (userId == null || userId.isEmpty) {
      try {
        final user = await getCurrentUser();
        userId = user.id;
        // Save it for future use
        await _secureStorage.write(key: 'user_id', value: userId);
      } catch (e) {
        print('Error fetching user ID: $e');
        return null;
      }
    }
    
    return userId;
  }

  /// Update user profile (name, email)
  Future<UserModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final userId = await _getUserId();
    print('DEBUG: Retrieved userId from storage: $userId'); // Debug
    
    if (userId == null || userId.isEmpty) {
      throw Exception('Usuario no autenticado');
    }

    print('DEBUG: Making PATCH request to /users/$userId'); // Debug
    
    final response = await _apiClient.patch(
      '/users/$userId',
      data: {
        'name': name,
        'email': email,
      },
    );
    return UserModel.fromJson(response.data);
  }

  /// Update user password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = await _getUserId();
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    await _apiClient.patch(
      '/users/$userId/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Get current user info
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response.data);
  }
}
