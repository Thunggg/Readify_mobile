import 'package:flutter/material.dart';
import '../../core/api/api_error.dart';
import 'cart_api.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _api = CartApi();
  bool _loading = true;
  List<dynamic> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.getCart();
      print('DEBUG cart response: ' + response.toString());
      final items =
          (response is Map &&
              response['data'] is Map &&
              response['data']['items'] is List)
          ? (response['data']['items'] as List)
                .where((e) => e is Map)
                .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map),
                )
                .toList()
          : <Map<String, dynamic>>[];
      print('DEBUG cart items: ' + items.toString());
      setState(() => _items = items);
    } catch (e) {
      setState(() => _error = prettyDioError(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _removeItem(String bookId) async {
    try {
      await _api.removeFromCart(bookId);
      _fetchCart();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(prettyDioError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _items.isEmpty
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear cart?'),
                        content: const Text('Remove all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await _api.clearCart();
                      _fetchCart();
                    }
                  },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : RefreshIndicator(
              onRefresh: _fetchCart,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: const Icon(Icons.book, color: Colors.deepPurple),
                      ),
                      title: Text(item['book']?['title'] ?? 'Book'),
                      subtitle: Text('Quantity: ${item['quantity'] ?? 1}'),
                      onTap: () async {
                        // show quantity editor popup
                        int q = (item['quantity'] is int)
                            ? item['quantity'] as int
                            : int.tryParse(
                                    (item['quantity'] ?? '1').toString(),
                                  ) ??
                                  1;
                        final newQty = await showDialog<int>(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text('Update quantity'),
                              content: StatefulBuilder(
                                builder: (c, setS) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => setS(
                                          () => q = (q - 1).clamp(1, 999),
                                        ),
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Text(
                                        q.toString(),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      IconButton(
                                        onPressed: () => setS(() => q = q + 1),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, q),
                                  child: const Text('Update'),
                                ),
                              ],
                            );
                          },
                        );
                        if (newQty != null && newQty != q) {
                          try {
                            await _api.updateQuantity({
                              'bookId': item['bookId']?.toString() ?? '',
                              'quantity': newQty,
                            });
                            await _fetchCart();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(prettyDioError(e))),
                            );
                          }
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeItem(item['bookId'].toString()),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: _items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.payment),
              label: const Text('Checkout'),
              backgroundColor: Colors.deepPurple,
            )
          : null,
    );
  }
}
