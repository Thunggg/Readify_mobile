import '../../core/api/api_client.dart';
import 'package:dio/dio.dart';

class WishlistApi {
  final _client = ApiClient.instance.dio;

  /// Returns the backend success response (map) so callers can use `data` (list) inside it.
  Future<dynamic> getWishlist() async {
    final res = await _client.get('/wishlist');
    return res.data;
  }

  Future<dynamic> getWishlistCount() async {
    final res = await _client.get('/wishlist/count');
    return res.data;
  }

  Future<void> addToWishlist(Map<String, dynamic> data) async {
    await _client.post('/wishlist', data: data);
  }

  Future<void> removeFromWishlist(String bookId) async {
    await _client.delete('/wishlist/$bookId');
  }

  Future<void> clearWishlist() async {
    await _client.delete('/wishlist');
  }

  Future<void> moveToCart(String bookId) async {
    await _client.post('/wishlist/move-to-cart/$bookId');
  }

  Future<dynamic> bulkMoveToCart(Map<String, dynamic> data) async {
    final res = await _client.post('/wishlist/bulk-move-to-cart', data: data);
    return res.data;
  }

  Future<dynamic> bulkRemove(Map<String, dynamic> data) async {
    final res = await _client.post('/wishlist/bulk-remove', data: data);
    return res.data;
  }

  Future<dynamic> checkBookInWishlist(String bookId) async {
    final res = await _client.get('/wishlist/check/$bookId');
    return res.data;
  }

  // Add more methods as needed (bulk, check, etc.)
}
