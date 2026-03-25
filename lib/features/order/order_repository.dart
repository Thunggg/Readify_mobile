import '../home/models/home_models.dart';

class OrderRepository {
  OrderRepository._();

  static final OrderRepository instance = OrderRepository._();

  final List<HomeOrder> _orders = [];

  List<HomeOrder> get orders => List.unmodifiable(_orders);

  void addOrder(HomeOrder order) {
    _orders.insert(0, order);
  }

  /// Update order status (returns true if order found and updated)
  bool updateOrderStatus(String id, String status) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return false;
    final o = _orders[idx];
    final updated = HomeOrder(
      id: o.id,
      createdAt: o.createdAt,
      total: o.total,
      status: status,
      items: o.items,
    );
    _orders[idx] = updated;
    return true;
  }

  /// Remove an order by id
  bool removeOrder(String id) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return false;
    _orders.removeAt(idx);
    return true;
  }

  void clear() {
    _orders.clear();
  }
}
