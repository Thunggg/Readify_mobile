part of 'home_screen.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId, this.initialBook});

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
  int _quantity = 1;
  // Mock available vouchers
  final List<_Voucher> _vouchers = const [
    _Voucher(code: 'NEWUSER10', label: 'Giảm 10%', percent: 10),
    _Voucher(code: 'SPRING50', label: 'Giảm 50.000đ', amount: 50000),
  ];
  _Voucher? _selectedVoucher;

  // Payment method
  PaymentMethod _paymentMethod = PaymentMethod.cod;

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
      appBar: AppBar(
        title: const Text('Chi tiết sách'),
        actions: [
          AnimatedBuilder(
            animation: CartService.instance,
            builder: (context, _) {
              final count = CartService.instance.totalCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
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

// Simple voucher model for UI-only demo
class _Voucher {
  final String code;
  final String label;
  final int? percent;
  final int? amount;

  const _Voucher({
    required this.code,
    required this.label,
    this.percent,
    this.amount,
  });
}

enum PaymentMethod { cod, vnpay }

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({super.key, required this.slug, this.initialPost});

  final String slug;
  final HomeBlogPost? initialPost;

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final HomeService _service = HomeService();
  final TextEditingController _commentNameController = TextEditingController();
  final TextEditingController _commentEmailController = TextEditingController();
  final TextEditingController _commentContentController =
      TextEditingController();

  HomeBlogPost? _post;
  List<HomeBlogPost> _relatedPosts = const [];
  List<HomeBlogComment> _comments = const [];
  bool _loading = true;
  bool _loadingRelated = true;
  bool _loadingComments = true;
  bool _submittingComment = false;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _loading = _post == null;
    _load();
    _loadRelated();
    _loadComments();
  }

  @override
  void dispose() {
    _commentNameController.dispose();
    _commentEmailController.dispose();
    _commentContentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final data = await _service.getBlogDetail(widget.slug);
    if (!mounted) return;
    setState(() {
      _post = data ?? _post;
      _loading = false;
    });
  }

  Future<void> _loadRelated() async {
    try {
      final items = await _service.getBlogs(sortBy: 'popular', limit: 6);
      if (!mounted) return;
      setState(() {
        _relatedPosts = items
            .where((item) => item.slug != widget.slug)
            .take(5)
            .toList(growable: false);
        _loadingRelated = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingRelated = false);
    }
  }

  Future<void> _loadComments() async {
    final postId = _post?.id;
    if (postId == null || postId.isEmpty) {
      if (mounted) setState(() => _loadingComments = false);
      return;
    }

    try {
      final comments = await _service.getBlogComments(
        postId,
        page: 1,
        limit: 30,
      );
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingComments = false);
    }
  }

  Future<void> _submitComment() async {
    final postId = _post?.id;
    final name = _commentNameController.text.trim();
    final email = _commentEmailController.text.trim();
    final content = _commentContentController.text.trim();

    if (postId == null || postId.isEmpty) return;
    if (name.isEmpty || email.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập đầy đủ tên, email và nội dung bình luận',
          ),
        ),
      );
      return;
    }

    setState(() => _submittingComment = true);
    try {
      await _service.createBlogComment(
        postId,
        authorName: name,
        authorEmail: email,
        content: content,
      );

      if (!mounted) return;
      _commentContentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi bình luận, vui lòng chờ duyệt')),
      );
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gửi bình luận thất bại: $e')));
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final publishedAtText = post?.publishedAt != null
        ? DateFormat('dd/MM/yyyy').format(post!.publishedAt!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài viết')),
      body: _loading && post == null
          ? const Center(child: CircularProgressIndicator())
          : post == null
          ? const Center(child: Text('Không có dữ liệu'))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 230,
                    child: _NetworkImage(url: post.featuredImage),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (publishedAtText != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(publishedAtText),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.visibility_outlined, size: 16),
                                const SizedBox(width: 4),
                                Text('${post.viewCount ?? 0} lượt xem'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (post.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: post.tags
                                .map((e) => Chip(label: Text('#$e')))
                                .toList(growable: false),
                          ),
                        const SizedBox(height: 18),
                        Text(
                          'Nội dung',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post.excerpt,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(height: 1.7),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Bài viết này hiện đang hiển thị phần tóm tắt. Có thể mở rộng trường nội dung đầy đủ khi backend trả về body/content.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                                height: 1.6,
                              ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Bình luận',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _commentNameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên của bạn',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentContentController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Nội dung bình luận',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _submittingComment
                                ? null
                                : _submitComment,
                            icon: _submittingComment
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_outlined),
                            label: Text(
                              _submittingComment
                                  ? 'Đang gửi...'
                                  : 'Gửi bình luận',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_loadingComments)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_comments.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: const Text('Chưa có bình luận nào'),
                          )
                        else
                          Column(
                            children: _comments
                                .map(
                                  (comment) => Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.03,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                comment.authorName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            if (comment.createdAt != null)
                                              Text(
                                                DateFormat(
                                                  'dd/MM/yyyy HH:mm',
                                                ).format(comment.createdAt!),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(comment.content),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Bài viết liên quan',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 238,
                    child: _loadingRelated
                        ? const Center(child: CircularProgressIndicator())
                        : _relatedPosts.isEmpty
                        ? const Center(
                            child: Text('Chưa có bài viết liên quan'),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final item = _relatedPosts[index];
                              return SizedBox(
                                width: 210,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BlogDetailScreen(
                                          slug: item.slug,
                                          initialPost: item,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.03,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.08,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: SizedBox(
                                              height: 110,
                                              width: double.infinity,
                                              child: _NetworkImage(
                                                url: item.featuredImage,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            item.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.excerpt,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemCount: _relatedPosts.length,
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
