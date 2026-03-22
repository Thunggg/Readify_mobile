import 'package:flutter/material.dart';

import '../../home/models/home_models.dart';

class BookResultCard extends StatelessWidget {
  const BookResultCard({
    super.key,
    required this.book,
    required this.isGrid,
    required this.priceText,
    required this.favorited,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  final HomeBook book;
  final bool isGrid;
  final String priceText;
  final bool favorited;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _NetworkImage(url: book.thumbnailUrl)),
              const SizedBox(height: 8),
              Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(book.authorText, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD54F)),
                  const SizedBox(width: 4),
                  Text((book.averageRating ?? 0).toStringAsFixed(1)),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(favorited ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text(priceText, maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Thêm vào giỏ',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
      ),
      leading: SizedBox(width: 46, child: _NetworkImage(url: book.thumbnailUrl)),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('${book.authorText}\n$priceText'),
      isThreeLine: true,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(favorited ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
            onPressed: onToggleFavorite,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_outlined),
            onPressed: onAddToCart,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class BookResultCardSkeleton extends StatelessWidget {
  const BookResultCardSkeleton({super.key, this.isGrid = true});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final base = Colors.white.withValues(alpha: 0.07);
    final line = Colors.white.withValues(alpha: 0.12);

    if (isGrid) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 12, width: double.infinity, color: line),
            const SizedBox(height: 6),
            Container(height: 10, width: 100, color: line),
            const SizedBox(height: 10),
            Container(height: 12, width: 80, color: line),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 64,
            decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: double.infinity, color: line),
                const SizedBox(height: 6),
                Container(height: 12, width: 140, color: line),
                const SizedBox(height: 8),
                Container(height: 10, width: 90, color: line),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final source = url;
    if (source == null || source.trim().isEmpty) {
      return _fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Icon(Icons.menu_book_rounded)),
    );
  }
}
