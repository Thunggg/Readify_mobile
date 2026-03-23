import '../../core/api/api_client.dart';
import 'package:dio/dio.dart';

class CartApi {
  final _client = ApiClient.instance.dio;

  /// Returns the backend success response (map) so callers can use `data`/`data['items']`.
  Future<dynamic> getCart() async {
    final res = await _client.get('/cart');
    return res.data;
  }

  Future<dynamic> getCartCount() async {
    final res = await _client.get('/cart/count');
    return res.data;
  }

  Future<void> addToCart(Map<String, dynamic> data) async {
    await _client.post('/cart', data: data);
  }

  Future<dynamic> getCartItem(String bookId) async {
    final res = await _client.get('/cart/item/$bookId');
    return res.data;
  }

  Future<dynamic> getSelectedItems() async {
    final res = await _client.get('/cart/selected');
    return res.data;
  }

  Future<dynamic> toggleSelectItem(String bookId) async {
    final res = await _client.patch('/cart/toggle-select/$bookId', {});
    return res.data;
  }

  Future<dynamic> updateItemSelection(Map<String, dynamic> data) async {
    final res = await _client.patch('/cart/update-selection', data: data);
    return res.data;
  }

  Future<dynamic> selectAllItems() async {
    final res = await _client.patch('/cart/select-all', {});
    return res.data;
  }

  Future<dynamic> deselectAllItems() async {
    final res = await _client.patch('/cart/deselect-all', {});
    return res.data;
  }

  Future<void> removeFromCart(String bookId) async {
    await _client.delete('/cart/$bookId');
  }

  Future<void> clearCart() async {
    await _client.delete('/cart');
  }

  Future<void> updateQuantity(Map<String, dynamic> data) async {
    await _client.put('/cart', data: data);
  }

  // Add more methods as needed (select, deselect, etc.)
}
