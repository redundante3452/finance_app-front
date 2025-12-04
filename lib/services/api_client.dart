import 'package:dio/dio.dart';
import 'package:finance_app/core/config/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage? _secureStorage;

  ApiClient({FlutterSecureStorage? secureStorage}) 
      : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: Constants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers if available
          if (_secureStorage != null) {
            final token = await _secureStorage!.read(key: 'auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized (token expired/invalid)
          if (error.response?.statusCode == 401) {
            // Clear token
            if (_secureStorage != null) {
              await _secureStorage!.delete(key: 'auth_token');
            }
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.patch(path, data: data, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data['message'] ?? e.response?.statusMessage;
      
      switch (statusCode) {
        case 400:
          return Exception('Bad Request: $message');
        case 401:
          return Exception('Unauthorized: Please login again');
        case 403:
          return Exception('Forbidden: $message');
        case 404:
          return Exception('Not Found: $message');
        case 409:
          return Exception('Conflict: $message');
        case 500:
          return Exception('Server Error: Please try again later');
        default:
          return Exception('API Error: $statusCode - $message');
      }
    } else {
      return Exception('Network Error: ${e.message}');
    }
  }
}
