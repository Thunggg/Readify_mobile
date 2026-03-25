import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_error.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio? _dio;
  Dio get dio => _dio ?? ApiClient.instance.dio;

  NotificationService({Dio? dio}) : _dio = dio;

  Future<List<NotificationModel>> getNotifications({bool? isRead, int limit = 20, int page = 1}) async {
    try {
      final queryParameters = {
        'limit': limit,
        'page': page,
        'sort': 'latest',
      };
      if (isRead != null) {
        queryParameters['isRead'] = isRead;
      }

      final res = await dio.get('/notifications', queryParameters: queryParameters);
      final data = _extractData(res.data, fallbackMessage: 'Failed to fetch notifications');

      dynamic itemsRaw = data;
      if (data is Map && data['items'] is List) {
        itemsRaw = data['items'];
      }

      if (itemsRaw is! List) return <NotificationModel>[];

      return itemsRaw
          .whereType<Map>()
          .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final res = await dio.patch('/notifications/$id/read');
      _extractData(res.data, fallbackMessage: 'Failed to mark notification as read');
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final res = await dio.patch('/notifications/read-all');
      _extractData(res.data, fallbackMessage: 'Failed to mark all notifications as read');
    } on DioException catch (e) {
      throw ApiError(prettyDioError(e), statusCode: e.response?.statusCode);
    }
  }

  Future<NotificationModel> getDetail(String id) async {
    try {
      final res = await dio.get('/notifications/$id');
      final data = _extractData(res.data, fallbackMessage: 'Failed to get notification detail');
      return NotificationModel.fromJson(Map<String, dynamic>.from(data));
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
