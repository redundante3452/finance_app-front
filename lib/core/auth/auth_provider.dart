import 'package:finance_app/core/auth/auth_service.dart';
import 'package:finance_app/core/models/user_model.dart';
import 'package:finance_app/core/providers/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthService(apiClient, secureStorage);
});

/// Authentication state provider
final authStateProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isAuthenticated();
});

/// Current user provider
final currentUserProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final isAuth = await authService.isAuthenticated();
  
  if (!isAuth) return null;
  
  try {
    return await authService.getCurrentUser();
  } catch (e) {
    // If token is invalid, return null
    return null;
  }
});

/// Stored user provider (from secure storage, no API call)
final storedUserProvider = FutureProvider.autoDispose<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getStoredUser();
});
