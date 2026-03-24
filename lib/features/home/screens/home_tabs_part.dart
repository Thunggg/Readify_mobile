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

class _BooksTab extends StatefulWidget {
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
  State<_BooksTab> createState() => _BooksTabState();
}

class _BooksTabState extends State<_BooksTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBookSearchPage([String? keyword]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookSearchFilterScreen(
          categories: widget.provider.bookCategories,
          currency: widget.currency,
          initialKeyword: keyword,
          onOpenDetail: widget.onOpenDetail,
          onToggleFavoriteBook: widget.onToggleFavoriteBook,
          isBookFavorited: widget.isBookFavorited,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) => _openBookSearchPage(val),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tiêu đề/tác giả',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => _openBookSearchPage(_searchController.text),
                tooltip: 'Mở trang lọc sách',
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _openBookSearchPage(),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('Mở trang Sách (Search / Sort / Filter)'),
            ),
          ),
          
        ],
      ),
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
    return posts.isEmpty
        ? const Center(child: Text('Chưa có bài viết'))
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            itemBuilder: (context, index) {
              final post = posts[index];
              final published = post.publishedAt != null ? DateFormat('dd/MM/yyyy').format(post.publishedAt!) : '--/--/----';

              return InkWell(
                onTap: () => onOpenDetail(post),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: SizedBox(
                    height: 100,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _NetworkImage(url: post.featuredImage),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  post.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  post.excerpt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 24,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$published • ${post.viewCount ?? 0} lượt xem',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                                      visualDensity: VisualDensity.compact,
                                      iconSize: 20,
                                      icon: Icon(
                                        isBlogFavorited(post.id) ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => onToggleFavoriteBlog(post),
                                    ),
                                  ],
                                ),
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
            separatorBuilder: (context, index) => const SizedBox(height: 10),
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

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({required this.provider});

  final HomeProvider provider;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> with AutomaticKeepAliveClientMixin {
  final ProfileApi _profileApi = ProfileApi();
  Map<String, dynamic>? _me;
  bool _loading = false;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  @override
  bool get wantKeepAlive => true;

  String _fullName(Map<String, dynamic> me) {
    final first = (me['firstName'] ?? '').toString().trim();
    final last = (me['lastName'] ?? '').toString().trim();
    final name = ('$first $last').trim();
    return name.isEmpty ? 'User' : name;
  }

  Future<void> _loadMe() async {
    setState(() {
      _loading = true;
      _isGuest = false;
    });
    try {
      final me = await _profileApi.getMe();
      if (!mounted) return;
      setState(() => _me = me);
    } catch (e) {
      if (!mounted) return;
      // 401 -> treat as guest
      final message = prettyDioError(e);
      setState(() {
        _me = null;
        _isGuest = message.toLowerCase().contains('unauthorized') || message.contains('(401)');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openProfile() async {
    if (_isGuest) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  Future<void> _logout() async {
    try {
      await AuthApi().logout();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final provider = widget.provider;
    final me = _me;
    final avatarUrl = (me?['avatarUrl'] ?? '').toString().trim();
    final hasAvatar = avatarUrl.isNotEmpty;
    final title = me == null ? 'Guest User' : _fullName(me);
    final subtitle = me == null ? 'Member' : (me['email'] ?? 'Member').toString();

    return RefreshIndicator(
      onRefresh: _loadMe,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: hasAvatar ? null : const Icon(Icons.person, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_loading) ...[
                          const SizedBox(width: 10),
                          const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.70)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
          if (_isGuest) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập để xem hồ sơ'),
              ),
            ),
          ],
          const SizedBox(height: 18),
          _ProfileMenuTile(
            title: 'Thông tin cá nhân',
            icon: Icons.badge_outlined,
            onTap: _openProfile,
          ),
          const _ProfileMenuTile(title: 'Sách yêu thích', icon: Icons.menu_book_outlined),
          const _ProfileMenuTile(title: 'Bài viết đã lưu', icon: Icons.bookmark_outline),
          const _ProfileMenuTile(title: 'Bình luận của tôi', icon: Icons.chat_bubble_outline),
          const _ProfileMenuTile(title: 'Cài đặt', icon: Icons.settings_outlined),
          _ProfileMenuTile(
            title: _isGuest ? 'Đăng nhập' : 'Đăng xuất',
            icon: _isGuest ? Icons.login : Icons.logout,
            onTap: _isGuest ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())) : _logout,
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({required this.title, required this.icon, this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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
