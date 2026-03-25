import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider({NotificationService? service})
      : _service = service ?? NotificationService();

  List<NotificationModel> notifications = const [];
  bool loading = false;
  String? error;
  int unreadCount = 0;

  Future<void> load({bool? unreadOnly, int limit = 20, int page = 1}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final items = await _service.getNotifications(isRead: unreadOnly == true ? false : null, limit: limit, page: page);
      notifications = items;
      _calculateUnreadCount();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      final index = notifications.indexWhere((e) => e.id == id);
      if (index != -1) {
        notifications[index].isRead = true;
        _calculateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      // Ignored
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      for (final n in notifications) {
        n.isRead = true;
      }
      unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  void _calculateUnreadCount() {
    unreadCount = notifications.where((e) => !e.isRead).length;
  }
}
