import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

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

  if (err is PlatformException) {
    final msg = err.message?.trim();
    if (msg != null && msg.isNotEmpty) return msg;
    return err.code.isNotEmpty ? err.code : 'Platform error';
  }

  if (err is MissingPluginException) {
    // Common after adding a new plugin and only doing hot reload.
    return 'Missing plugin. Please stop the app and run again (full restart).';
  }

  if (err is FormatException) {
    return err.message.isNotEmpty ? err.message : 'Invalid format';
  }

  return err.toString();
}

