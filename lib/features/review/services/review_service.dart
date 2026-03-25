import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../models/review_model.dart';

class ReviewService {
  final Dio? _dio;
  Dio get dio => _dio ?? ApiClient.instance.dio;

  ReviewService({Dio? dio}) : _dio = dio;

  Future<List<ReviewModel>> getBookReviews(String bookId, {int limit = 20, int page = 1}) async {
    try {
      final res = await dio.get('/reviews/book/$bookId', queryParameters: {
        'limit': limit,
        'page': page,
      });
      final data = _extractData(res.data, fallbackMessage: 'Failed to fetch reviews');

      dynamic itemsRaw = data;
      if (data is Map && data['items'] is List) {
        itemsRaw = data['items'];
      }

      if (itemsRaw is! List) return <ReviewModel>[];

      return itemsRaw
          .whereType<Map>()
          .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ReviewModel> addReview({
    required String bookId,
    required String content,
    required double rating,
  }) async {
    try {
      final res = await dio.post('/reviews', data: {
        'bookId': bookId,
        'comment': content,
        'rating': rating,
      });
      final data = _extractData(res.data, fallbackMessage: 'Failed to add review');
      return ReviewModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<ReviewModel> updateReview({
    required String reviewId,
    required String content,
    required double rating,
  }) async {
    try {
      final res = await dio.patch('/reviews/$reviewId', data: {
        'comment': content,
        'rating': rating,
      });
      final data = _extractData(res.data, fallbackMessage: 'Failed to update review');
      return ReviewModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      final res = await dio.delete('/reviews/$reviewId');
      _extractData(res.data, fallbackMessage: 'Failed to delete review');
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
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
}
