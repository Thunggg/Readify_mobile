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
    if (provider.loading)
      return const Center(child: CircularProgressIndicator());

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
          Text(
            'Danh mục / Tag phổ biến',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...provider.bookCategories
                  .take(8)
                  .map((e) => Chip(label: Text('Book: ${e.name}'))),
              ...provider.blogCategories
                  .take(8)
                  .map((e) => Chip(label: Text('Blog: ${e.name}'))),
              ...provider.popularTags
                  .take(10)
                  .map((e) => Chip(label: Text('#$e'))),
            ],
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
    if (provider.loading)
      return const Center(child: CircularProgressIndicator());
    return posts.isEmpty
        ? const Center(child: Text('Chưa có bài viết'))
        : ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            itemBuilder: (context, index) {
              final post = posts[index];
              final published = post.publishedAt != null
                  ? DateFormat('dd/MM/yyyy').format(post.publishedAt!)
                  : '--/--/----';
              return InkWell(
                onTap: () => onOpenDetail(post),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
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
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  post.excerpt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
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
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                    IconButton(
                                      iconSize: 20,
                                      icon: Icon(
                                        isBlogFavorited(post.id)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          onToggleFavoriteBlog(post),
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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.provider});

  final HomeProvider provider;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: provider.avatarUrl != null
                      ? NetworkImage(provider.avatarUrl!)
                      : null,
                  child: provider.avatarUrl == null
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.userName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.userEmail,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () async {
                              final nameCtrl = TextEditingController(
                                text: provider.userName,
                              );
                              final emailCtrl = TextEditingController(
                                text: provider.userEmail,
                              );
                              final avatarCtrl = TextEditingController(
                                text: provider.avatarUrl ?? '',
                              );
                              final saved = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Chỉnh sửa thông tin'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: nameCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Tên',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: emailCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: avatarCtrl,
                                          decoration: const InputDecoration(
                                            labelText: 'URL avatar (tuỳ chọn)',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Huỷ'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Lưu'),
                                    ),
                                  ],
                                ),
                              );

                              if (saved == true) {
                                provider.updateProfile(
                                  name: nameCtrl.text.trim().isEmpty
                                      ? provider.userName
                                      : nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  avatar: avatarCtrl.text.trim().isEmpty
                                      ? null
                                      : avatarCtrl.text.trim(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Cập nhật thông tin thành công',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Chỉnh sửa'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              provider.fetchOrders();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OrderScreen(provider: provider),
                                ),
                              );
                            },
                            child: const Text('Xem đơn hàng'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CountChip(
              label: 'Sách đã lưu',
              value: provider.favoriteBooks.length,
            ),
            _CountChip(
              label: 'Bài viết đã like',
              value: provider.favoriteBlogs.length,
            ),
            _CountChip(label: 'Bình luận', value: provider.myCommentCount),
          ],
        ),
        const SizedBox(height: 18),

        // const SizedBox(height: 6),
        // const Text(
        //   'Đơn hàng của tôi',
        //   style: TextStyle(fontWeight: FontWeight.w700),
        // ),
        // const SizedBox(height: 8),
        // if (provider.orders.isEmpty)
        //   const Text(
        //     'Bạn chưa có đơn hàng nào. Nhấn "Tải đơn hàng" để xem demo.',
        //   ),
        // if (provider.orders.isNotEmpty)
        //   ...provider.orders.map(
        //     (o) => Card(
        //       margin: const EdgeInsets.symmetric(vertical: 6),
        //       child: ListTile(
        //         title: Text('Đơn ${o.id} • ${o.status}'),
        //         subtitle: Text('${o.shortDate} • ${o.items.length} mặt hàng'),
        //         trailing: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           crossAxisAlignment: CrossAxisAlignment.end,
        //           children: [
        //             Text('${o.total}đ'),
        //             const SizedBox(height: 4),
        //             TextButton(
        //               onPressed: () {
        //                 showModalBottomSheet(
        //                   context: context,
        //                   builder: (_) => Padding(
        //                     padding: const EdgeInsets.all(12),
        //                     child: Column(
        //                       mainAxisSize: MainAxisSize.min,
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         Text(
        //                           'Chi tiết đơn ${o.id}',
        //                           style: Theme.of(context).textTheme.titleMedium
        //                               ?.copyWith(fontWeight: FontWeight.w700),
        //                         ),
        //                         const SizedBox(height: 8),
        //                         ...o.items.map(
        //                           (it) => Padding(
        //                             padding: const EdgeInsets.symmetric(
        //                               vertical: 4,
        //                             ),
        //                             child: Row(
        //                               mainAxisAlignment:
        //                                   MainAxisAlignment.spaceBetween,
        //                               children: [
        //                                 Text(it.title),
        //                                 Text('${it.quantity} x ${it.price}đ'),
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                         const SizedBox(height: 8),
        //                         Text(
        //                           'Tổng: ${o.total}đ',
        //                           style: const TextStyle(
        //                             fontWeight: FontWeight.w700,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 );
        //               },
        //               child: const Text('Chi tiết'),
        //               style: TextButton.styleFrom(
        //                 padding: EdgeInsets.zero,
        //                 minimumSize: const Size(40, 24),
        //                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        //               ),
        //             ),
        //           ],
        //         ),
        //         onTap: () {
        //           showModalBottomSheet(
        //             context: context,
        //             builder: (_) => Padding(
        //               padding: const EdgeInsets.all(12),
        //               child: Column(
        //                 mainAxisSize: MainAxisSize.min,
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   Text(
        //                     'Chi tiết đơn ${o.id}',
        //                     style: Theme.of(context).textTheme.titleMedium
        //                         ?.copyWith(fontWeight: FontWeight.w700),
        //                   ),
        //                   const SizedBox(height: 8),
        //                   ...o.items.map(
        //                     (it) => Padding(
        //                       padding: const EdgeInsets.symmetric(vertical: 4),
        //                       child: Row(
        //                         mainAxisAlignment:
        //                             MainAxisAlignment.spaceBetween,
        //                         children: [
        //                           Text(it.title),
        //                           Text('${it.quantity} x ${it.price}đ'),
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                   const SizedBox(height: 8),
        //                   Text(
        //                     'Tổng: ${o.total}đ',
        //                     style: const TextStyle(fontWeight: FontWeight.w700),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           );
        //         },
        //       ),
        //     ),
        // ),
        const SizedBox(height: 12),
        const _ProfileMenuTile(
          title: 'Sách yêu thích',
          icon: Icons.menu_book_outlined,
        ),
        const _ProfileMenuTile(
          title: 'Bài viết đã lưu',
          icon: Icons.bookmark_outline,
        ),
        const _ProfileMenuTile(
          title: 'Bình luận của tôi',
          icon: Icons.chat_bubble_outline,
        ),
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
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(label),
        ],
      ),
    );
  }
}
