class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException(this.message, {this.code, this.originalException});

  @override
  String toString() {
    if (code != null) return 'AppException[$code]: $message';
    return 'AppException: $message';
  }
}
