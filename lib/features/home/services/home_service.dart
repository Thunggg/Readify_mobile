import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../models/home_models.dart';

class HomeBookQuery {
  const HomeBookQuery({
    this.page = 1,
    this.limit = 12,
    this.keyword,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sort = 'newest',
  });

  final int page;
  final int limit;
  final String? keyword;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String sort;

  Map<String, dynamic> toParams() {
    final map = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort': sort,
    };

    final q = keyword?.trim() ?? '';
    if (q.isNotEmpty) map['q'] = q;

    final category = categoryId?.trim() ?? '';
    if (category.isNotEmpty) map['categoryId'] = category;

    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;

    return map;
  }
}

class HomeBookPageResult {
  const HomeBookPageResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<HomeBook> items;
  final int page;
  final int limit;
  final int total;

  bool get hasNext => page * limit < total;
}

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

  Future<HomeBookPageResult> getBooksPage(HomeBookQuery query) async {
    try {
      final res = await _dio.get('/book', queryParameters: query.toParams());

      final data = _extractDataMap(res.data, fallbackMessage: 'Get books failed');
      final itemsRaw = data['items'];
      final metaRaw = data['meta'];

      final items = itemsRaw is List
          ? itemsRaw
              .whereType<Map>()
              .map((e) => HomeBook.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : <HomeBook>[];

      if (metaRaw is Map) {
        final meta = Map<String, dynamic>.from(metaRaw);
        final page = _asInt(meta['page']) ?? query.page;
        final limit = _asInt(meta['limit']) ?? query.limit;
        final total = _asInt(meta['total']) ?? items.length;

        return HomeBookPageResult(items: items, page: page, limit: limit, total: total);
      }

      return HomeBookPageResult(items: items, page: query.page, limit: query.limit, total: items.length);
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<List<HomeBook>> searchBooks(String keyword, {int limit = 6}) async {
    try {
      final res = await _dio.get('/book', queryParameters: {
        'page': 1,
        'limit': limit,
        'q': keyword,
        'sort': 'newest',
      });

      final data = _extractDataMap(res.data, fallbackMessage: 'Search books failed');
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

  Future<List<HomeBook>> getRelatedBooks(String bookId, {int limit = 8}) async {
    try {
      final res = await _dio.get('/book/$bookId/related', queryParameters: {'limit': limit});
      final data = _extractData(res.data, fallbackMessage: 'Get related books failed');

      dynamic itemsRaw = data;
      if (data is Map && data['items'] is List) {
        itemsRaw = data['items'];
      }

      if (itemsRaw is! List) return const [];

      return itemsRaw
          .whereType<Map>()
          .map((e) => HomeBook.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
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

  Future<List<HomeBlogPost>> searchBlogs(String keyword, {int limit = 6}) async {
    try {
      final res = await _dio.get('/blog/posts', queryParameters: {
        'page': 1,
        'limit': limit,
        'search': keyword,
        'sortBy': 'newest',
      });
      final data = _extractDataMap(res.data, fallbackMessage: 'Search blogs failed');
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

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
