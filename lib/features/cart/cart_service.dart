import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../home/models/home_models.dart';

import 'cart_models.dart';

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final Map<String, CartItem> _items = {};

  UnmodifiableListView<CartItem> get items =>
      UnmodifiableListView(_items.values);

  int get totalPrice =>
      _items.values.fold<int>(0, (sum, it) => sum + it.lineTotal);

  int get totalCount =>
      _items.values.fold<int>(0, (sum, it) => sum + it.quantity);

  void add(HomeBook book) {
    final id = book.id;
    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(book: book, quantity: 1);
    }
    notifyListeners();
  }

  void remove(String bookId) {
    _items.remove(bookId);
    notifyListeners();
  }

  void updateQuantity(String bookId, int qty) {
    final item = _items[bookId];
    if (item == null) return;
    if (qty <= 0) {
      _items.remove(bookId);
    } else {
      item.quantity = qty;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
