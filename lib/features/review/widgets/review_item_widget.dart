import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review_model.dart';
import 'star_rating_widgets.dart';

class ReviewItemWidget extends StatelessWidget {
  final ReviewModel review;
  final bool isMyReview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReviewItemWidget({
    super.key,
    required this.review,
    this.isMyReview = false,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null ? const Icon(Icons.person, size: 20) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        StarRatingDisplay(rating: review.rating, size: 12),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(review.createdAt),
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isMyReview)
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'edit') {
                      onEdit();
                    } else if (val == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                    const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                  ],
                  child: const Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.content,
            style: const TextStyle(height: 1.4),
          ),
        ],
      ),
    );
  }
}
