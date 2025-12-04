import 'package:finance_app/features/accounts/models/account_model.dart';
import 'package:finance_app/features/accounts/services/account_service.dart';
import 'package:finance_app/features/categories/models/category_model.dart';
import 'package:finance_app/features/categories/services/category_service.dart';
import 'package:finance_app/features/transactions/models/transaction_model.dart';
import 'package:finance_app/features/transactions/services/transaction_service.dart';
import 'package:finance_app/services/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: secureStorage);
});

// Account Service Provider
final accountServiceProvider = Provider<AccountService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AccountService(apiClient);
});

// Category Service Provider
final categoryServiceProvider = Provider<CategoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CategoryService(apiClient);
});

// Transaction Service Provider
final transactionServiceProvider = Provider<TransactionApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransactionApiService(apiClient);
});

// Accounts List Provider
final accountsProvider = FutureProvider.autoDispose<List<AccountModel>>((ref) async {
  final service = ref.watch(accountServiceProvider);
  return service.getAccounts();
});

// Categories List Provider
final categoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategories();
});

// Transactions List Provider
final transactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>((ref) async {
  final service = ref.watch(transactionServiceProvider);
  return service.getTransactions();
});
