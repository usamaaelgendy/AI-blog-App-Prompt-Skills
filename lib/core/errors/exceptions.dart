class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
