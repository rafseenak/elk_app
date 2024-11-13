class NetworkException implements Exception {
  final int statusCode;
  final String message;

  const NetworkException({required this.statusCode, required this.message});

  @override
  String toString() =>
      'Network expption: stauscode:$statusCode, message: $message';
}
