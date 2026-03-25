import 'package:flutter/material.dart';
import '../models/review_model.dart';
import 'star_rating_widgets.dart';

class AddEditReviewDialog extends StatefulWidget {
  final ReviewModel? initialReview;
  final String? bookId;

  const AddEditReviewDialog({
    super.key,
    this.initialReview,
    this.bookId,
  }) : assert(initialReview != null || bookId != null);

  @override
  State<AddEditReviewDialog> createState() => _AddEditReviewDialogState();
}

class _AddEditReviewDialogState extends State<AddEditReviewDialog> {
  late final TextEditingController _controller;
  double _rating = 0;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialReview?.content ?? '');
    _rating = widget.initialReview?.rating ?? 5.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      setState(() => _error = 'Vui lòng nhập nội dung đánh giá');
      return;
    }
    if (_rating <= 0) {
      setState(() => _error = 'Vui lòng chọn mức độ đánh giá (sao)');
      return;
    }

    Navigator.of(context).pop({
      'content': content,
      'rating': _rating,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialReview != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEdit ? 'Chỉnh sửa đánh giá' : 'Thêm đánh giá',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text('Mức độ đánh giá:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Center(
              child: StarRatingInput(
                rating: _rating,
                onChanged: (val) => setState(() => _rating = val),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nội dung:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung đánh giá của bạn...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7F04A),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(isEdit ? 'Cập nhật' : 'Gửi đi'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
