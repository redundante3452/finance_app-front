import 'package:finance_app/features/transactions/models/transaction_model.dart';
import 'package:finance_app/services/api_client.dart';

class TransactionApiService {
  final ApiClient _apiClient;

  TransactionApiService(this._apiClient);

  Future<List<TransactionModel>> getTransactions() async {
    final response = await _apiClient.get('/transactions');
    final List<dynamic> data = response.data;
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<TransactionModel> createTransaction(Map<String, dynamic> transactionData) async {
    final response = await _apiClient.post(
      '/transactions',
      data: transactionData,
    );
    return TransactionModel.fromJson(response.data);
  }

  Future<void> deleteTransaction(String id) async {
    await _apiClient.delete('/transactions/$id');
  }

  Future<TransactionModel> updateTransaction(String id, Map<String, dynamic> transactionData) async {
    final response = await _apiClient.patch(
      '/transactions/$id',
      data: transactionData,
    );
    return TransactionModel.fromJson(response.data);
  }
}
