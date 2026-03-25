import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _service;

  ReviewProvider({ReviewService? service})
      : _service = service ?? ReviewService();

  List<ReviewModel> reviews = const [];
  bool loading = false;
  String? error;

  Future<void> loadBookReviews(String bookId, {int limit = 20, int page = 1}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final items = await _service.getBookReviews(bookId, limit: limit, page: page);
      reviews = items;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> addReview({
    required String bookId,
    required String content,
    required double rating,
  }) async {
    try {
      final newReview = await _service.addReview(bookId: bookId, content: content, rating: rating);
      reviews = [newReview, ...reviews];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required String content,
    required double rating,
  }) async {
    try {
      final updatedReview = await _service.updateReview(reviewId: reviewId, content: content, rating: rating);
      final index = reviews.indexWhere((e) => e.id == reviewId);
      if (index != -1) {
        final list = List<ReviewModel>.from(reviews);
        list[index] = updatedReview;
        reviews = list;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _service.deleteReview(reviewId);
      reviews = reviews.where((e) => e.id != reviewId).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
