import 'package:finance_app/features/categories/models/category_model.dart';
import 'package:finance_app/services/api_client.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/categories');
    final List<dynamic> data = response.data;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> categoryData) async {
    final response = await _apiClient.post(
      '/categories',
      data: categoryData,
    );
    return CategoryModel.fromJson(response.data);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _apiClient.delete(
      '/categories/$categoryId',
    );
  }
}
