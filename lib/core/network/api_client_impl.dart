import 'package:dio/dio.dart';
import 'api_client.dart';

class ApiClientImpl implements ApiClient {
  final Dio _dio;

  ApiClientImpl(this._dio);

  @override
  Future<T> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  }) async {
    final response = await _dio.get(endpoint);
    if (fromJson != null) return fromJson(response.data);
    if (fromJsonList != null) return fromJsonList(response.data);
    return response.data as T;
  }

  @override
  Future<T> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _dio.post(endpoint, data: body);
    if (fromJson != null) return fromJson(response.data);
    return response.data as T;
  }

  @override
  Future<T> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _dio.put(endpoint, data: body);
    if (fromJson != null) return fromJson(response.data);
    return response.data as T;
  }

  @override
  Future<void> delete(String endpoint) async {
    await _dio.delete(endpoint);
  }
}
