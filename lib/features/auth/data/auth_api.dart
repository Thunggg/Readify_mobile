import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';

class AuthApi {
  AuthApi({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<void> login({required String email, required String password}) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = res.data;
      if (data is Map && data['success'] == true) return;
      if (data is Map && data['message'] is String) {
        throw ApiError(data['message'] as String, statusCode: res.statusCode);
      }
      throw ApiError('Login failed', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required String dateOfBirthIso,
    required int sex,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'address': address,
          'dateOfBirth': dateOfBirthIso,
          'sex': sex,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      final data = res.data;
      if (data is Map && data['success'] == true) return;
      if (data is Map && data['message'] is String) {
        throw ApiError(data['message'] as String, statusCode: res.statusCode);
      }
      throw ApiError('Register failed', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> verifyRegisterOtp({required String otp}) async {
    try {
      final res = await _dio.post(
        '/accounts/otp/verify',
        data: {'otp': otp},
      );

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
      throw ApiError('OTP verify failed', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> resendRegisterOtp() async {
    try {
      final res = await _dio.post('/accounts/otp/resend');
      final data = res.data;
      if (data is Map && data['success'] == true) return;
      if (data is Map && data['message'] is String) {
        throw ApiError(data['message'] as String, statusCode: res.statusCode);
      }
      throw ApiError('Resend OTP failed', statusCode: res.statusCode);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }
}

