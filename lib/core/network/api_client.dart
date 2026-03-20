/// Abstract API client — Dependency Inversion Principle
/// The app depends on this interface, not the concrete Dio implementation.
abstract class ApiClient {
  Future<T> get<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    T Function(List<dynamic>)? fromJsonList,
  });

  Future<T> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<T> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  });

  Future<void> delete(String endpoint);
}
