import 'package:dio/dio.dart';

class DioNetworkEception {
  static String? handeleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? error.response?.statusMessage!;
    } else {
      String? returnError;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          returnError = 'Connection Timeout Exception';
          break;
        case DioExceptionType.sendTimeout:
          returnError = 'Send Timeout Exception';
          break;
        case DioExceptionType.receiveTimeout:
          returnError = 'Receive Timeout Exception';
          break;
        case DioExceptionType.cancel:
          returnError = 'Request to API server was cancelled';
          break;
        case DioExceptionType.unknown:
          returnError = 'Unexpected error: ${error.message}';
          break;
        default:
          returnError = 'Unhandled error: ${error.message}';
      }
      return returnError;
    }
  }
}
