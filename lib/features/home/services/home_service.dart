import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../models/home_models.dart';

class HomeService {
  HomeService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  final Dio _dio;

  Future<List<HomeBook>> getBooks({required String sort, int limit = 6}) async {
    try {
      final res = await _dio.get('/book', queryParameters: {
        'page': 1,
        'limit': limit,
        'sort': sort,
      });

      final data = _extractDataMap(res.data, fallbackMessage: 'Get books failed');
      final items = data['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map>()
          .map((e) => HomeBook.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<HomeBook?> getBookDetail(String bookId) async {
    try {
      final res = await _dio.get('/book/$bookId');
      final data = _extractDataMap(res.data, fallbackMessage: 'Get book detail failed');
      return HomeBook.fromJson(data);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<List<HomeBlogPost>> getBlogs({required String sortBy, int limit = 4}) async {
    try {
      final res = await _dio.get('/blog/posts', queryParameters: {
        'page': 1,
        'limit': limit,
        'sortBy': sortBy,
      });
      final data = _extractDataMap(res.data, fallbackMessage: 'Get blogs failed');
      final items = data['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map>()
          .map((e) => HomeBlogPost.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<HomeBlogPost?> getBlogDetail(String slug) async {
    try {
      final res = await _dio.get('/blog/posts/$slug');
      final data = _extractDataMap(res.data, fallbackMessage: 'Get blog detail failed');
      return HomeBlogPost.fromJson(data);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<List<HomeCategory>> getBookCategories({int limit = 20}) async {
    try {
      final res = await _dio.get('/categories', queryParameters: {
        'page': 1,
        'limit': limit,
        'sortBy': 'name',
        'order': 'asc',
      });
      final data = _extractDataMap(res.data, fallbackMessage: 'Get categories failed');
      final items = data['items'];
      if (items is! List) return const [];

      return items
          .whereType<Map>()
          .map((e) => HomeCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<List<HomeCategory>> getBlogCategories() async {
    try {
      final res = await _dio.get('/blog/categories');
      final rawData = _extractData(res.data, fallbackMessage: 'Get blog categories failed');
      if (rawData is! List) return const [];

      return rawData
          .whereType<Map>()
          .map((e) => HomeCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }
}

dynamic _extractData(dynamic payload, {required String fallbackMessage}) {
  if (payload is Map) {
    if (payload['success'] == true) return payload['data'];
    final message = payload['message'];
    if (message is String && message.trim().isNotEmpty) {
      throw ApiError(message.trim());
    }
    throw ApiError(fallbackMessage);
  }
  throw ApiError(fallbackMessage);
}

Map<String, dynamic> _extractDataMap(dynamic payload, {required String fallbackMessage}) {
  final data = _extractData(payload, fallbackMessage: fallbackMessage);
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  throw ApiError(fallbackMessage);
}
