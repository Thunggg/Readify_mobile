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
  final NumberFormat _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

  HomeBook? _book;
  List<HomeBook> _relatedBooks = const [];
  bool _loading = true;
  bool _loadingRelated = true;

  @override
  void initState() {
    super.initState();
    _book = widget.initialBook;
    _loading = _book == null;
    _load();
    _loadRelated();
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

  @override
  Widget build(BuildContext context) {
    final book = _book;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sách'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng giỏ hàng đang phát triển')),
              );
            },
          ),
        ],
      ),
      body: _loading && book == null
          ? const Center(child: CircularProgressIndicator())
          : book == null
              ? const Center(child: Text('Không tìm thấy dữ liệu sách'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Cover
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Center(
                          child: Hero(
                            tag: 'book_cover_${book.id}',
                            child: Container(
                              height: 280,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _NetworkImage(url: book.thumbnailUrl),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Title & Author
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 20, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    book.authorText,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            // Price & Rating
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _currency.format(book.basePrice),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: const Color(0xFFB7F04A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        (book.averageRating ?? 0).toStringAsFixed(1),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Categories
                            if (book.categories.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: book.categories.map((c) => Chip(
                                  label: Text(c.name),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                                  side: BorderSide.none,
                                )).toList(),
                              ),
                            ],

                            const SizedBox(height: 24),
                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
                                      );
                                    },
                                    icon: const Icon(Icons.add_shopping_cart),
                                    label: const Text('Thêm vào giỏ'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {},
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Mua ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                            // Description Section
                            Text(
                              'Giới thiệu sách',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              book.description ?? 'Chưa có mô tả cho sách này.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Related Books
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Sách cùng thể loại',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: _loadingRelated
                            ? const Center(child: CircularProgressIndicator())
                            : _relatedBooks.isEmpty
                                ? const Center(child: Text('Chưa có sách liên quan'))
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      final item = _relatedBooks[index];
                                      return SizedBox(
                                        width: 140,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => BookDetailScreen(bookId: item.id, initialBook: item),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: SizedBox(
                                                    width: 140,
                                                    child: _NetworkImage(url: item.thumbnailUrl),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                item.title, 
                                                maxLines: 2, 
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _currency.format(item.basePrice),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(color: Color(0xFFB7F04A), fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                                    itemCount: _relatedBooks.length,
                                  ),
                      ),
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
  final TextEditingController _commentNameController = TextEditingController();
  final TextEditingController _commentEmailController = TextEditingController();
  final TextEditingController _commentContentController = TextEditingController();

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
      final comments = await _service.getBlogComments(postId, page: 1, limit: 30);
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
        const SnackBar(content: Text('Vui lòng nhập đầy đủ tên, email và nội dung bình luận')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gửi bình luận thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final publishedAtText = post?.publishedAt != null ? DateFormat('dd/MM/yyyy').format(post!.publishedAt!) : null;

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
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
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
                                      const Icon(Icons.calendar_today_outlined, size: 14),
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
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              post.excerpt,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Bài viết này hiện đang hiển thị phần tóm tắt. Có thể mở rộng trường nội dung đầy đủ khi backend trả về body/content.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    height: 1.6,
                                  ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Bình luận',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                                onPressed: _submittingComment ? null : _submitComment,
                                icon: _submittingComment
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.send_outlined),
                                label: Text(_submittingComment ? 'Đang gửi...' : 'Gửi bình luận'),
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
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                                          color: Colors.white.withValues(alpha: 0.03),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    comment.authorName,
                                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                                  ),
                                                ),
                                                if (comment.createdAt != null)
                                                  Text(
                                                    DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt!),
                                                    style: Theme.of(context).textTheme.bodySmall,
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
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 238,
                        child: _loadingRelated
                            ? const Center(child: CircularProgressIndicator())
                            : _relatedPosts.isEmpty
                                ? const Center(child: Text('Chưa có bài viết liên quan'))
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
                                                builder: (_) => BlogDetailScreen(slug: item.slug, initialPost: item),
                                              ),
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(12),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.03),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: SizedBox(
                                                      height: 110,
                                                      width: double.infinity,
                                                      child: _NetworkImage(url: item.featuredImage),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    item.title,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontWeight: FontWeight.w700),
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
                                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                                    itemCount: _relatedPosts.length,
                                  ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
