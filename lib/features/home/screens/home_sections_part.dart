part of 'home_screen.dart';

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
      ],
    );
  }
}

class _HeroBanners extends StatefulWidget {
  const _HeroBanners({
    required this.items,
    required this.onTapBook,
    required this.onTapBlog,
  });

  final List<HomeBannerItem> items;
  final ValueChanged<HomeBook> onTapBook;
  final ValueChanged<HomeBlogPost> onTapBlog;

  @override
  State<_HeroBanners> createState() => _HeroBannersState();
}

class _HeroBannersState extends State<_HeroBanners> {
  final PageController _controller = PageController(viewportFraction: 0.93);
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 190,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, idx) {
          final item = widget.items[idx];
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(colors: [Color(0xFF1E2434), Color(0xFF10131C)]),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(item.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    if (item.type == 'book' && item.book != null) {
                      widget.onTapBook(item.book!);
                      return;
                    }
                    if (item.type == 'blog' && item.blog != null) {
                      widget.onTapBlog(item.blog!);
                    }
                  },
                  child: Text(item.ctaLabel),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.items.length,
                      (dot) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: _index == dot ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _index == dot ? const Color(0xFFB7F04A) : Colors.white30,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookHorizontal extends StatelessWidget {
  const _BookHorizontal({
    required this.books,
    required this.currency,
    required this.onOpenDetail,
    required this.onToggleFavoriteBook,
    required this.isBookFavorited,
  });

  final List<HomeBook> books;
  final NumberFormat currency;
  final ValueChanged<HomeBook> onOpenDetail;
  final ValueChanged<HomeBook> onToggleFavoriteBook;
  final bool Function(String id) isBookFavorited;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const Text('Chưa có dữ liệu');
    }

    return SizedBox(
      height: 252,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final book = books[index];
          return SizedBox(
            width: 170,
            child: InkWell(
              onTap: () => onOpenDetail(book),
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _NetworkImage(url: book.thumbnailUrl)),
                      const SizedBox(height: 8),
                      Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(book.authorText, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(child: Text(currency.format(book.basePrice), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(isBookFavorited(book.id) ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                            onPressed: () => onToggleFavoriteBook(book),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlogList extends StatelessWidget {
  const _BlogList({
    required this.posts,
    required this.onOpenDetail,
    required this.onToggleFavoriteBlog,
    required this.isBlogFavorited,
  });

  final List<HomeBlogPost> posts;
  final ValueChanged<HomeBlogPost> onOpenDetail;
  final ValueChanged<HomeBlogPost> onToggleFavoriteBlog;
  final bool Function(String id) isBlogFavorited;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Text('Chưa có bài viết');
    }

    return Column(
      children: posts
          .map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => onOpenDetail(post),
                tileColor: Colors.white.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                leading: SizedBox(width: 46, child: _NetworkImage(url: post.featuredImage)),
                title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(post.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: Icon(isBlogFavorited(post.id) ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                  onPressed: () => onToggleFavoriteBlog(post),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _FeaturedBlogCards extends StatelessWidget {
  const _FeaturedBlogCards({
    required this.posts,
    required this.onOpenDetail,
    required this.onToggleFavoriteBlog,
    required this.isBlogFavorited,
  });

  final List<HomeBlogPost> posts;
  final ValueChanged<HomeBlogPost> onOpenDetail;
  final ValueChanged<HomeBlogPost> onToggleFavoriteBlog;
  final bool Function(String id) isBlogFavorited;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const Text('Chưa có bài viết nổi bật');

    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final post = posts[index];
          return SizedBox(
            width: 248,
            child: InkWell(
              onTap: () => onOpenDetail(post),
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 120, width: double.infinity, child: _NetworkImage(url: post.featuredImage)),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(child: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          IconButton(
                            icon: Icon(isBlogFavorited(post.id) ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
                            onPressed: () => onToggleFavoriteBlog(post),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.priceText,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleFavorite,
    required this.favorited,
    this.isGrid = true,
  });

  final HomeBook book;
  final String priceText;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;
  final bool favorited;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                    const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text((book.averageRating ?? 0).toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: Text(priceText, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Thêm vào giỏ',
                      onPressed: onAddToCart,
                      icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Yêu thích',
                      icon: Icon(favorited ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent, size: 18),
                      onPressed: onToggleFavorite,
                    ),
                  ],
                ),
              ],
            ),
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(book.authorText, maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
              const SizedBox(width: 4),
              Text((book.averageRating ?? 0).toStringAsFixed(1)),
              const SizedBox(width: 8),
              Expanded(child: Text(priceText, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
      trailing: SizedBox(
        width: 70,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onAddToCart,
              icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
              tooltip: 'Thêm vào giỏ',
            ),
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(favorited ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent, size: 18),
              tooltip: 'Yêu thích',
            ),
          ],
        ),
      ),
    );
  }
}

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key, this.isGrid = true});

  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    if (isGrid) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: box),
            const SizedBox(height: 8),
            Container(height: 12, width: double.infinity, color: Colors.white.withValues(alpha: 0.10)),
            const SizedBox(height: 6),
            Container(height: 10, width: 100, color: Colors.white.withValues(alpha: 0.10)),
            const SizedBox(height: 10),
            Container(height: 10, width: 70, color: Colors.white.withValues(alpha: 0.10)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          SizedBox(width: 46, height: 64, child: box),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: double.infinity, color: Colors.white.withValues(alpha: 0.10)),
                const SizedBox(height: 6),
                Container(height: 10, width: 120, color: Colors.white.withValues(alpha: 0.10)),
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

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blueGrey.withValues(alpha: 0.35),
            Colors.blueGrey.withValues(alpha: 0.15),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 26, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(height: 6),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safe = url?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: safe.isEmpty
          ? _buildFallback()
          : Image.network(
              safe,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallback();
              },
            ),
    );
  }
}
