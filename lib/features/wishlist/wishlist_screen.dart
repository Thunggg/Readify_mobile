import 'package:flutter/material.dart';
import '../../core/api/api_error.dart';
import 'wishlist_api.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _api = WishlistApi();
  bool _loading = true;
  List<dynamic> _items = [];
  String? _error;
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.getWishlist();

      // `WishlistApi.getWishlist()` now returns `res.data` from Dio,
      // which is a Map like { success, message, data: [...] }
      final response = res; // already the parsed data

      print('DEBUG wishlist response: ' + response.toString());

      final items = (response is Map && response['data'] is List)
          ? (response['data'] as List)
                .where((e) => e is Map)
                .map<Map<String, dynamic>>(
                  (e) => Map<String, dynamic>.from(e as Map),
                )
                .toList()
          : <Map<String, dynamic>>[];

      setState(() => _items = items);
    } catch (e) {
      setState(() => _error = prettyDioError(e));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _removeItem(String bookId) async {
    try {
      await _api.removeFromWishlist(bookId);
      _fetchWishlist();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(prettyDioError(e))));
    }
  }

  Future<void> _moveToCart(String bookId) async {
    try {
      await _api.moveToCart(bookId);
      _fetchWishlist();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Moved to cart!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(prettyDioError(e))));
    }
  }

  Future<void> _moveSelectedToCart() async {
    if (_selectedIds.isEmpty) return;
    try {
      await _api.bulkMoveToCart({'bookIds': _selectedIds.toList()});
      _selectedIds.clear();
      await _fetchWishlist();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Moved selected to cart')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(prettyDioError(e))));
    }
  }

  Future<void> _removeSelected() async {
    if (_selectedIds.isEmpty) return;
    try {
      await _api.bulkRemove({'bookIds': _selectedIds.toList()});
      _selectedIds.clear();
      await _fetchWishlist();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed selected')));
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
        title: const Text('Your Wishlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _items.isEmpty
                ? null
                : () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear wishlist?'),
                        content: const Text(
                          'Remove all items from your wishlist?',
                        ),
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
                      await _api.clearWishlist();
                      _fetchWishlist();
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
          ? const Center(child: Text('Your wishlist is empty'))
          : RefreshIndicator(
              onRefresh: _fetchWishlist,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  final Map<String, dynamic>? book = (item['bookId'] is Map)
                      ? Map<String, dynamic>.from(item['bookId'])
                      : (item['book'] is Map)
                      ? Map<String, dynamic>.from(item['book'])
                      : null;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: _selectedIds.contains(
                          item['_id'] ?? item['bookId']?.toString(),
                        ),
                        onChanged: (v) {
                          final id =
                              item['_id'] ??
                              (item['bookId'] is Map
                                  ? item['bookId']['_id']?.toString()
                                  : item['bookId']?.toString());
                          if (id == null) return;
                          setState(() {
                            if (v == true)
                              _selectedIds.add(id);
                            else
                              _selectedIds.remove(id);
                          });
                        },
                      ),
                      title: Text(
                        book != null ? (book['title'] ?? 'Book') : 'Book',
                      ),
                      subtitle: Text(
                        book != null && book['authors'] is List
                            ? (book['authors'] as List)
                                  .map(
                                    (a) => a is Map
                                        ? (a['name'] ?? '')
                                        : a.toString(),
                                  )
                                  .where((s) => s != null && s != '')
                                  .join(', ')
                            : '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.deepPurple,
                            ),
                            tooltip: 'Move to cart',
                            onPressed: () {
                              String id = '';
                              if (item['bookId'] is Map &&
                                  item['bookId']['_id'] != null) {
                                id = item['bookId']['_id'].toString();
                              } else if (item['bookId'] != null) {
                                id = item['bookId'].toString();
                              }
                              if (id.isNotEmpty) _moveToCart(id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              String id = '';
                              if (item['bookId'] is Map &&
                                  item['bookId']['_id'] != null) {
                                id = item['bookId']['_id'].toString();
                              } else if (item['bookId'] != null) {
                                id = item['bookId'].toString();
                              }
                              if (id.isNotEmpty) _removeItem(id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: _selectedIds.isNotEmpty
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: Row(
                  children: [
                    Text('${_selectedIds.length} selected'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _removeSelected,
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _moveSelectedToCart,
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Move to cart'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
