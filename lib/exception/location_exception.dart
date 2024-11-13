import 'package:elk/data/enum/location_status_code.dart';

class LocationException implements Exception {
  final LocationStatusCode statusCode;
  final String message;

  const LocationException({required this.statusCode, required this.message});

  @override
  String toString() =>
      'Network exception: stauscode:${statusCode.toString()}, message: $message';
}
