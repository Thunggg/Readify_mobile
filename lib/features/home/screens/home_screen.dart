import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/home_models.dart';
import '../providers/home_provider.dart';
import '../services/home_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeProvider _provider = HomeProvider();
  final NumberFormat _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _provider.loadHome();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
      ),
      body: AnimatedBuilder(
        animation: _provider,
        builder: (context, _) {
          if (_provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_provider.errorMessage != null && _provider.featuredBooks.isEmpty && _provider.newestBlogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Không tải được dữ liệu trang chủ'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _provider.loadHome,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _provider.loadHome,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
              children: [
                _HeroSection(
                  items: _provider.banners,
                  onTapBook: (book) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id, initialBook: book)),
                    );
                  },
                  onTapBlog: (post) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: post.slug, initialPost: post)),
                    );
                  },
                  onExplore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookListScreen(
                          title: 'Tất cả sách nổi bật',
                          books: _provider.featuredBooks,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _SectionTitle(
                  title: 'Sách nổi bật',
                  onViewAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookListScreen(
                          title: 'Sách nổi bật',
                          books: _provider.featuredBooks,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _BookHorizontalList(
                  books: _provider.featuredBooks,
                  currency: _currency,
                  onTap: (book) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id, initialBook: book)),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _SectionTitle(
                  title: 'Sách mới nhất',
                  onViewAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookListScreen(
                          title: 'Sách mới nhất',
                          books: _provider.newestBooks,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _BookHorizontalList(
                  books: _provider.newestBooks,
                  currency: _currency,
                  onTap: (book) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id, initialBook: book)),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _SectionTitle(
                  title: 'Bài viết mới nhất',
                  onViewAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlogListScreen(
                          title: 'Bài viết mới nhất',
                          posts: _provider.newestBlogs,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _BlogVerticalList(
                  posts: _provider.newestBlogs.take(6).toList(growable: false),
                  onTap: (post) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: post.slug, initialPost: post)),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _SectionTitle(
                  title: 'Bài viết nổi bật',
                  onViewAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlogListScreen(
                          title: 'Bài viết nổi bật',
                          posts: _provider.featuredBlogs,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _FeaturedBlogCards(
                  posts: _provider.featuredBlogs.take(4).toList(growable: false),
                  onTap: (post) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: post.slug, initialPost: post)),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Danh mục / Tag phổ biến',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._provider.bookCategories.take(8).map(
                      (e) => ActionChip(
                        label: Text('Book: ${e.name}'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Danh mục sách: ${e.name}')),
                          );
                        },
                      ),
                    ),
                    ..._provider.blogCategories.take(8).map(
                      (e) => ActionChip(
                        label: Text('Blog: ${e.name}'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Danh mục blog: ${e.name}')),
                          );
                        },
                      ),
                    ),
                    ..._provider.popularTags.take(10).map(
                      (e) => ActionChip(
                        label: Text('#$e'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Tag: #$e')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onViewAll});

  final String title;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
      ],
    );
  }
}

class _HeroSection extends StatefulWidget {
  const _HeroSection({
    required this.items,
    required this.onTapBook,
    required this.onTapBlog,
    required this.onExplore,
  });

  final List<HomeBannerItem> items;
  final void Function(HomeBook book) onTapBook;
  final void Function(HomeBlogPost post) onTapBlog;
  final VoidCallback onExplore;

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  final PageController _controller = PageController(viewportFraction: 0.94);
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, i) {
              final item = widget.items[i];
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F2535), Color(0xFF0E111A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        if (item.type == 'book' && item.book != null) {
                          widget.onTapBook(item.book!);
                          return;
                        }
                        if (item.type == 'blog' && item.blog != null) {
                          widget.onTapBlog(item.blog!);
                          return;
                        }
                        widget.onExplore();
                      },
                      child: Text(item.ctaLabel),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _index == i ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _index == i ? const Color(0xFFB7F04A) : Colors.white24,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookHorizontalList extends StatelessWidget {
  const _BookHorizontalList({
    required this.books,
    required this.currency,
    required this.onTap,
  });

  final List<HomeBook> books;
  final NumberFormat currency;
  final void Function(HomeBook book) onTap;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return const Text('Chưa có dữ liệu');
    }

    return SizedBox(
      height: 255,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final book = books[index];
          return SizedBox(
            width: 165,
            child: InkWell(
              onTap: () => onTap(book),
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
                    Expanded(child: _NetworkOrFallbackImage(url: book.thumbnailUrl)),
                    const SizedBox(height: 8),
                    Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      book.authorText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text((book.averageRating ?? 0).toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.format(book.basePrice),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFB7F04A),
                            fontWeight: FontWeight.w700,
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

class _BlogVerticalList extends StatelessWidget {
  const _BlogVerticalList({required this.posts, required this.onTap});

  final List<HomeBlogPost> posts;
  final void Function(HomeBlogPost post) onTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Text('Chưa có bài viết');
    }

    return Column(
      children: posts.map((post) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onTap(post),
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 86,
                    height: 70,
                    child: _NetworkOrFallbackImage(url: post.featuredImage),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          post.excerpt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _FeaturedBlogCards extends StatelessWidget {
  const _FeaturedBlogCards({required this.posts, required this.onTap});

  final List<HomeBlogPost> posts;
  final void Function(HomeBlogPost post) onTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Text('Chưa có bài viết nổi bật');
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final post = posts[index];
          return SizedBox(
            width: 240,
            child: InkWell(
              onTap: () => onTap(post),
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: _NetworkOrFallbackImage(url: post.featuredImage),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
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

class _NetworkOrFallbackImage extends StatelessWidget {
  const _NetworkOrFallbackImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final safeUrl = url?.trim() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: safeUrl.isEmpty
          ? Container(
              color: Colors.white.withValues(alpha: 0.06),
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported_outlined),
            )
          : Image.network(
              safeUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white.withValues(alpha: 0.06),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                );
              },
            ),
    );
  }
}

class BookListScreen extends StatelessWidget {
  const BookListScreen({
    super.key,
    required this.title,
    required this.books,
  });

  final String title;
  final List<HomeBook> books;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemBuilder: (context, index) {
          final book = books[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            leading: SizedBox(width: 44, child: _NetworkOrFallbackImage(url: book.thumbnailUrl)),
            title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(book.authorText, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Text(currency.format(book.basePrice)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id, initialBook: book)),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: books.length,
      ),
    );
  }
}

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({
    super.key,
    required this.title,
    required this.posts,
  });

  final String title;
  final List<HomeBlogPost> posts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            contentPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
            ),
            leading: SizedBox(width: 44, child: _NetworkOrFallbackImage(url: post.featuredImage)),
            title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(post.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: post.slug, initialPost: post)),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: posts.length,
      ),
    );
  }
}

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({
    super.key,
    required this.bookId,
    this.initialBook,
  });

  final String bookId;
  final HomeBook? initialBook;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final HomeService _service = HomeService();
  final NumberFormat _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  HomeBook? _book;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _book = widget.initialBook;
    _loading = _book == null;
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getBookDetail(widget.bookId);
    if (!mounted) return;
    setState(() {
      _book = data ?? _book;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = _book;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sách')),
      body: _loading && book == null
          ? const Center(child: CircularProgressIndicator())
          : book == null
              ? const Center(child: Text('Không có dữ liệu'))
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    SizedBox(height: 260, child: _NetworkOrFallbackImage(url: book.thumbnailUrl)),
                    const SizedBox(height: 12),
                    Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(book.authorText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 10),
                    Text(
                      _currency.format(book.basePrice),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFB7F04A),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text('Đánh giá: ${(book.averageRating ?? 0).toStringAsFixed(1)}'),
                    const SizedBox(height: 10),
                    Text(book.description ?? 'Chưa có mô tả'),
                  ],
                ),
    );
  }
}

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({
    super.key,
    required this.slug,
    this.initialPost,
  });

  final String slug;
  final HomeBlogPost? initialPost;

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final HomeService _service = HomeService();
  HomeBlogPost? _post;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _loading = _post == null;
    _load();
  }

  Future<void> _load() async {
    final data = await _service.getBlogDetail(widget.slug);
    if (!mounted) return;
    setState(() {
      _post = data ?? _post;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài viết')),
      body: _loading && post == null
          ? const Center(child: CircularProgressIndicator())
          : post == null
              ? const Center(child: Text('Không có dữ liệu'))
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    SizedBox(height: 220, child: _NetworkOrFallbackImage(url: post.featuredImage)),
                    const SizedBox(height: 12),
                    Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    Text(post.excerpt),
                    const SizedBox(height: 10),
                    if (post.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.tags.map((e) => Chip(label: Text('#$e'))).toList(growable: false),
                      ),
                  ],
                ),
    );
  }
}
