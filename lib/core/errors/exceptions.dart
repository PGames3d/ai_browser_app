class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error occurred']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network connection failed']);
}

class StorageException implements Exception {
  final String message;
  StorageException([this.message = 'Storage error occurred']);
}

class FileNotFoundException implements Exception {
  final String message;
  FileNotFoundException([this.message = 'File not found']);
}

class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException([this.message = 'Permission denied']);
}
