import 'package:flutter/material.dart';
import 'book_api.dart';
import '../cart/cart_api.dart';
import '../wishlist/wishlist_api.dart';
import '../../core/auth_helpers.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _book;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await BookApi().getBookDetail(widget.bookId);
      setState(() => _book = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 260,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(_book?['title'] ?? 'Book'),
                    background:
                        _book != null &&
                            (_book!['cover'] != null ||
                                _book!['thumbnail'] != null)
                        ? Image.network(
                            (_book!['cover'] ?? _book!['thumbnail']).toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200]),
                          )
                        : Container(color: Colors.grey[200]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_book != null &&
                              (_book!['cover'] != null ||
                                  _book!['thumbnail'] != null))
                            Container(
                              width: 120,
                              height: 180,
                              margin: const EdgeInsets.only(right: 16),
                              child: Image.network(
                                (_book!['cover'] ?? _book!['thumbnail'])
                                    .toString(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: Colors.grey[200]),
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _book?['title'] ?? '',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _authorsString(_book),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                if (_book != null && _book!['rating'] != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber[700],
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(_book!['rating'].toString()),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _book?['shortDescription'] ??
                            _book?['description'] ??
                            '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final ok = await ensureLoggedIn(context);
                                if (!ok) return;
                                // show quantity selector
                                final qty = await showDialog<int>(
                                  context: context,
                                  builder: (ctx) {
                                    int value = 1;
                                    return AlertDialog(
                                      title: const Text('Add to cart'),
                                      content: StatefulBuilder(
                                        builder: (c, setS) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () => setS(
                                                  () => value = (value - 1)
                                                      .clamp(1, 999),
                                                ),
                                                icon: const Icon(Icons.remove),
                                              ),
                                              Text(
                                                value.toString(),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => setS(
                                                  () => value = value + 1,
                                                ),
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
                                          onPressed: () =>
                                              Navigator.pop(ctx, value),
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (qty == null) return;
                                final cartApi = CartApi();
                                try {
                                  await cartApi.addToCart({
                                    'bookId': _book?['_id'] ?? widget.bookId,
                                    'quantity': qty,
                                  });
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Added to cart'),
                                      ),
                                    );
                                } catch (e) {
                                  if (mounted)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                }
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: const Text('Add to cart'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final ok = await ensureLoggedIn(context);
                              if (!ok) return;
                              final wishlistApi = WishlistApi();
                              try {
                                await wishlistApi.addToWishlist({
                                  'bookId': _book?['_id'] ?? widget.bookId,
                                });
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Added to wishlist'),
                                    ),
                                  );
                              } catch (e) {
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                              }
                            },
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Wishlist'),
                          ),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  String _authorsString(Map<String, dynamic>? book) {
    if (book == null) return '';
    final a = book['authors'];
    if (a is List && a.isNotEmpty) {
      return a
          .map((e) => e is Map ? (e['name'] ?? '') : e.toString())
          .where((s) => s != null && s != '')
          .join(', ');
    }
    if (book['author'] != null) return book['author'].toString();
    return '';
  }
}
