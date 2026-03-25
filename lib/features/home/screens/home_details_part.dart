part of 'home_screen.dart';

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
  final ReviewProvider _reviewProvider = ReviewProvider();
  final ProfileApi _profileApi = ProfileApi();
  final NumberFormat _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  HomeBook? _book;
  List<HomeBook> _relatedBooks = const [];
  String? _myUserId;
  bool _loading = true;
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    _book = widget.initialBook;
    _loading = _book == null;
    _load();
    _loadRelated();
    _loadReviews();
    _loadProfile();
  }

  @override
  void dispose() {
    _reviewProvider.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _service.getBookDetail(widget.bookId);
    if (!mounted) return;
    setState(() {
      _book = data ?? _book;
      _loading = false;
    });
  }

  Future<void> _loadRelated() async {
    try {
      final items = await _service.getRelatedBooks(widget.bookId, limit: 8);
      if (!mounted) return;
      setState(() {
        _relatedBooks = items;
        _loadingRelated = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRelated = false);
    }
  }

  Future<void> _loadReviews() async {
    await _reviewProvider.loadBookReviews(widget.bookId);
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileApi.getMe();
      if (!mounted) return;
      setState(() => _myUserId = profile['_id']?.toString() ?? profile['id']?.toString());
    } catch (_) {}
  }

  Future<void> _addReview() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditReviewDialog(bookId: widget.bookId),
    );

    if (result != null) {
      try {
        await _reviewProvider.addReview(
          bookId: widget.bookId,
          content: result['content'],
          rating: result['rating'],
        );
        _load(); // Refresh book average rating
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _editReview(ReviewModel review) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddEditReviewDialog(initialReview: review),
    );

    if (result != null) {
      try {
        await _reviewProvider.updateReview(
          reviewId: review.id,
          content: result['content'],
          rating: result['rating'],
        );
        _load(); // Refresh book average rating
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _reviewProvider.deleteReview(reviewId);
        _load(); // Refresh book average rating
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
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
              : ListenableBuilder(
                  listenable: _reviewProvider,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      SizedBox(height: 260, child: _NetworkImage(url: book.thumbnailUrl)),
                      const SizedBox(height: 12),
                      Text(book.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text(book.authorText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currency.format(book.basePrice),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFFB7F04A),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Row(
                            children: [
                              StarRatingDisplay(rating: book.averageRating ?? 0, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                (book.averageRating ?? 0).toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mô tả',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(book.description ?? 'Chưa có mô tả', style: const TextStyle(height: 1.5, color: Colors.white70)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Đánh giá & Nhận xét',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextButton.icon(
                            onPressed: _addReview,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Viết đánh giá'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_reviewProvider.loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_reviewProvider.reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('Chưa có đánh giá nào cho cuốn sách này')),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviewProvider.reviews.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final review = _reviewProvider.reviews[index];
                            return ReviewItemWidget(
                              review: review,
                              isMyReview: review.userId == _myUserId,
                              onEdit: () => _editReview(review),
                              onDelete: () => _deleteReview(review.id),
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'Sách liên quan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 230,
                        child: _loadingRelated
                            ? const Center(child: CircularProgressIndicator())
                            : _relatedBooks.isEmpty
                                ? const Center(child: Text('Chưa có sách liên quan'))
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      final item = _relatedBooks[index];
                                      return SizedBox(
                                        width: 150,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => BookDetailScreen(bookId: item.id, initialBook: item),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Ink(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.04),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(child: _NetworkImage(url: item.thumbnailUrl)),
                                                const SizedBox(height: 6),
                                                Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _currency.format(item.basePrice),
                                                  maxLines: 1,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB7F04A)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                                    itemCount: _relatedBooks.length,
                                  ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
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
                    SizedBox(height: 220, child: _NetworkImage(url: post.featuredImage)),
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
