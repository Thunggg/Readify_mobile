import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';

class ProfileApi {
  ProfileApi({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _dio.get('/accounts/me');
      final data = res.data;
      if (data is Map && data['success'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) return payload;
        if (payload is Map) return Map<String, dynamic>.from(payload);
        return <String, dynamic>{};
      }
      if (data is Map && data['message'] is String) {
        throw ApiError(data['message'] as String, statusCode: res.statusCode);
      }
      throw ApiError('Failed to load profile', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> patch) async {
    try {
      final res = await _dio.patch('/accounts/me', data: patch);
      final data = res.data;
      if (data is Map && data['success'] == true) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) return payload;
        if (payload is Map) return Map<String, dynamic>.from(payload);
        return <String, dynamic>{};
      }
      if (data is Map && data['message'] is String) {
        throw ApiError(data['message'] as String, statusCode: res.statusCode);
      }
      throw ApiError('Failed to update profile', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final res = await _dio.patch(
        '/accounts/me/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      final data = res.data;
      if (data is Map && data['success'] == true) return;
      if (data is Map && data['message'] is String) {
        throw ApiError(data['message'] as String, statusCode: res.statusCode);
      }
      throw ApiError('Failed to change password', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }
}

