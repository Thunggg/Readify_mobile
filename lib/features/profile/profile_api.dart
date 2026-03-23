import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error.dart';

class ProfileApi {
  ProfileApi({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  Future<Map<String, dynamic>> getMe() async {
    try {
      final res = await _dio.get('/accounts/me');
      final data = res.data;
      if (data is Map && data['success'] == true && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data']);
      }
      throw ApiError('Failed to fetch profile');
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }
}
