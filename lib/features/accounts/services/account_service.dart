import 'package:finance_app/features/accounts/models/account_model.dart';
import 'package:finance_app/services/api_client.dart';

class AccountService {
  final ApiClient _apiClient;

  AccountService(this._apiClient);

  Future<List<AccountModel>> getAccounts() async {
    final response = await _apiClient.get('/accounts');
    final List<dynamic> data = response.data;
    return data.map((json) => AccountModel.fromJson(json)).toList();
  }

  Future<AccountModel> createAccount(Map<String, dynamic> accountData) async {
    final response = await _apiClient.post(
      '/accounts',
      data: accountData,
    );
    return AccountModel.fromJson(response.data);
  }

  Future<void> deleteAccount(String accountId) async {
    await _apiClient.delete(
      '/accounts/$accountId',
    );
  }

  Future<AccountModel> updateAccount(String id, Map<String, dynamic> accountData) async {
    final response = await _apiClient.patch(
      '/accounts/$id',
      data: accountData,
    );
    return AccountModel.fromJson(response.data);
  }
}
