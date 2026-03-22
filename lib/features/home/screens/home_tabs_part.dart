part of 'home_screen.dart';

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.provider,
    required this.currency,
    required this.onOpenBooksTab,
    required this.onOpenBlogsTab,
    required this.onOpenBookDetail,
    required this.onOpenBlogDetail,
    required this.onToggleFavoriteBook,
    required this.onToggleFavoriteBlog,
    required this.isBookFavorited,
    required this.isBlogFavorited,
  });

  final HomeProvider provider;
  final NumberFormat currency;
  final VoidCallback onOpenBooksTab;
  final VoidCallback onOpenBlogsTab;
  final ValueChanged<HomeBook> onOpenBookDetail;
  final ValueChanged<HomeBlogPost> onOpenBlogDetail;
  final ValueChanged<HomeBook> onToggleFavoriteBook;
  final ValueChanged<HomeBlogPost> onToggleFavoriteBlog;
  final bool Function(String id) isBookFavorited;
  final bool Function(String id) isBlogFavorited;

  @override
  Widget build(BuildContext context) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: provider.loadHome,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 22),
        children: [
          _HeroBanners(
            items: provider.banners,
            onTapBook: onOpenBookDetail,
            onTapBlog: onOpenBlogDetail,
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Sách nổi bật', onViewAll: onOpenBooksTab),
          const SizedBox(height: 8),
          _BookHorizontal(
            books: provider.featuredBooks,
            currency: currency,
            onOpenDetail: onOpenBookDetail,
            onToggleFavoriteBook: onToggleFavoriteBook,
            isBookFavorited: isBookFavorited,
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Sách mới nhất', onViewAll: onOpenBooksTab),
          const SizedBox(height: 8),
          _BookHorizontal(
            books: provider.newestBooks,
            currency: currency,
            onOpenDetail: onOpenBookDetail,
            onToggleFavoriteBook: onToggleFavoriteBook,
            isBookFavorited: isBookFavorited,
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Bài viết mới nhất', onViewAll: onOpenBlogsTab),
          const SizedBox(height: 8),
          _BlogList(
            posts: provider.newestBlogs.take(6).toList(growable: false),
            onOpenDetail: onOpenBlogDetail,
            onToggleFavoriteBlog: onToggleFavoriteBlog,
            isBlogFavorited: isBlogFavorited,
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Bài viết nổi bật', onViewAll: onOpenBlogsTab),
          const SizedBox(height: 8),
          _FeaturedBlogCards(
            posts: provider.featuredBlogs.take(4).toList(growable: false),
            onOpenDetail: onOpenBlogDetail,
            onToggleFavoriteBlog: onToggleFavoriteBlog,
            isBlogFavorited: isBlogFavorited,
          ),
          const SizedBox(height: 16),
          Text('Danh mục / Tag phổ biến', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...provider.bookCategories.take(8).map((e) => Chip(label: Text('Book: ${e.name}'))),
              ...provider.blogCategories.take(8).map((e) => Chip(label: Text('Blog: ${e.name}'))),
              ...provider.popularTags.take(10).map((e) => Chip(label: Text('#$e'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _BooksTab extends StatelessWidget {
  const _BooksTab({
    required this.provider,
    required this.currency,
    required this.onOpenDetail,
    required this.onToggleFavoriteBook,
    required this.isBookFavorited,
  });

  final HomeProvider provider;
  final NumberFormat currency;
  final ValueChanged<HomeBook> onOpenDetail;
  final ValueChanged<HomeBook> onToggleFavoriteBook;
  final bool Function(String id) isBookFavorited;

  @override
  Widget build(BuildContext context) {
    final books = provider.allBooks;

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (books.isEmpty) {
      return const Center(child: Text('Chưa có sách'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          onTap: () => onOpenDetail(book),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
          ),
          leading: SizedBox(width: 44, child: _NetworkImage(url: book.thumbnailUrl)),
          title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('${book.authorText}\n${currency.format(book.basePrice)}'),
          isThreeLine: true,
          trailing: IconButton(
            icon: Icon(isBookFavorited(book.id) ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
            onPressed: () => onToggleFavoriteBook(book),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: books.length,
    );
  }
}

class _BlogsTab extends StatelessWidget {
  const _BlogsTab({
    required this.provider,
    required this.onOpenDetail,
    required this.onToggleFavoriteBlog,
    required this.isBlogFavorited,
  });

  final HomeProvider provider;
  final ValueChanged<HomeBlogPost> onOpenDetail;
  final ValueChanged<HomeBlogPost> onToggleFavoriteBlog;
  final bool Function(String id) isBlogFavorited;

  @override
  Widget build(BuildContext context) {
    final posts = provider.allBlogs;

    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (posts.isEmpty) {
      return const Center(child: Text('Chưa có bài viết'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(
          onTap: () => onOpenDetail(post),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
          ),
          leading: SizedBox(width: 44, child: _NetworkImage(url: post.featuredImage)),
          title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(post.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: Icon(isBlogFavorited(post.id) ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
            onPressed: () => onToggleFavoriteBlog(post),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: posts.length,
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({
    required this.provider,
    required this.currency,
    required this.onOpenBookDetail,
    required this.onOpenBlogDetail,
  });

  final HomeProvider provider;
  final NumberFormat currency;
  final ValueChanged<HomeBook> onOpenBookDetail;
  final ValueChanged<HomeBlogPost> onOpenBlogDetail;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Sách đã lưu'), Tab(text: 'Bài viết đã like/lưu')]),
          Expanded(
            child: TabBarView(
              children: [
                provider.favoriteBooks.isEmpty
                    ? const Center(child: Text('Chưa có sách yêu thích'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final book = provider.favoriteBooks[index];
                          return ListTile(
                            onTap: () => onOpenBookDetail(book),
                            leading: SizedBox(width: 44, child: _NetworkImage(url: book.thumbnailUrl)),
                            title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text(currency.format(book.basePrice)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => provider.removeFavoriteBook(book.id),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemCount: provider.favoriteBooks.length,
                      ),
                provider.favoriteBlogs.isEmpty
                    ? const Center(child: Text('Chưa có bài viết yêu thích'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final post = provider.favoriteBlogs[index];
                          return ListTile(
                            onTap: () => onOpenBlogDetail(post),
                            leading: SizedBox(width: 44, child: _NetworkImage(url: post.featuredImage)),
                            title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                            subtitle: Text(post.excerpt, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => provider.removeFavoriteBlog(post.id),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemCount: provider.favoriteBlogs.length,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.provider});

  final HomeProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 28)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.userName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Text('Member'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CountChip(label: 'Sách đã lưu', value: provider.favoriteBooks.length),
            _CountChip(label: 'Bài viết đã like', value: provider.favoriteBlogs.length),
            _CountChip(label: 'Bình luận', value: provider.myCommentCount),
          ],
        ),
        const SizedBox(height: 18),
        const _ProfileMenuTile(title: 'Thông tin cá nhân', icon: Icons.badge_outlined),
        const _ProfileMenuTile(title: 'Sách yêu thích', icon: Icons.menu_book_outlined),
        const _ProfileMenuTile(title: 'Bài viết đã lưu', icon: Icons.bookmark_outline),
        const _ProfileMenuTile(title: 'Bình luận của tôi', icon: Icons.chat_bubble_outline),
        const _ProfileMenuTile(title: 'Cài đặt', icon: Icons.settings_outlined),
        const _ProfileMenuTile(title: 'Đăng xuất', icon: Icons.logout),
      ],
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(label),
        ],
      ),
    );
  }
}
