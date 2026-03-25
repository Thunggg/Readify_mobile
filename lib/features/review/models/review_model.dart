class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String bookId;
  final String content;
  final double rating;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.bookId,
    required this.content,
    required this.rating,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] ?? json['user'];
    String userId = '';
    String userName = 'Người dùng';
    String? userAvatar;

    if (user is Map) {
      userId = (user['_id'] ?? user['id'] ?? '').toString();
      userName = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
      if (userName.isEmpty) userName = user['email']?.toString() ?? 'Người dùng';
      userAvatar = user['avatarUrl']?.toString();
    } else {
      userId = user?.toString() ?? '';
    }

    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      bookId: (json['bookId'] ?? json['book'] ?? '').toString(),
      content: (json['comment'] ?? json['content'] ?? '').toString(),
      rating: _toDouble(json['rating']),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
