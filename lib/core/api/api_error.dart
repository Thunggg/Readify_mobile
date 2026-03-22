import 'package:dio/dio.dart';

class ApiError implements Exception {
  ApiError(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiError(statusCode: $statusCode, message: $message)';
}

String prettyDioError(Object err) {
  if (err is ApiError) return err.message;

  if (err is DioException) {
    final data = err.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    final status = err.response?.statusCode;
    if (status != null) return 'Request failed ($status)';
    return err.message ?? 'Network error';
  }

  return 'Unexpected error';
}

