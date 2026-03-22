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

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final safe = url?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: safe.isEmpty
          ? Container(
              color: Colors.white.withValues(alpha: 0.08),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined),
            )
          : Image.network(
              safe,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white.withValues(alpha: 0.08),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                );
              },
            ),
    );
  }
}
