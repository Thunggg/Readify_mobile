import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error.dart';

class BookApi {
  BookApi({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;
  final Dio _dio;

  Future<List<Map<String, dynamic>>> getBooks({String? search}) async {
    try {
      final res = await _dio.get(
        '/book',
        queryParameters: search != null && search.isNotEmpty
            ? {'q': search}
            : null,
      );
      final data = res.data;
      if (data is Map && data['success'] == true) {
        // support two shapes: data is a list or data contains an object with items list
        if (data['data'] is List)
          return List<Map<String, dynamic>>.from(data['data']);
        if (data['data'] is Map && data['data']['items'] is List) {
          return (data['data']['items'] as List)
              .where((e) => e is Map)
              .map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map),
              )
              .toList();
        }
      }
      throw ApiError('Failed to fetch books');
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> getBookDetail(String id) async {
    try {
      final res = await _dio.get('/book/$id');
      final data = res.data;
      if (data is Map && data['success'] == true) {
        // data could be the book object directly or wrapped under data
        if (data['data'] is Map) return Map<String, dynamic>.from(data['data']);
        if (data['data'] == null && data is Map)
          return Map<String, dynamic>.from(data);
      }
      throw ApiError('Failed to fetch book detail');
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }
}
