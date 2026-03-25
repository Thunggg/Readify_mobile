import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;
  final String? type;
  final String? deepLink;
  final String? imageUrl;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type,
    this.deepLink,
    this.imageUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      type: json['type'],
      deepLink: json['deepLink'],
      imageUrl: json['imageUrl'],
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(createdAt);
    }
  }
}
