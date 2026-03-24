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
  bool _showFullDescription = false;

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

    Widget infoBadge(IconData icon, String label) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.8)),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart feature is under development')),
              );
            },
          ),
        ],
      ),
      body: _loading && book == null
          ? const Center(child: CircularProgressIndicator())
          : book == null
              ? const Center(child: Text('No book data found'))
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

                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                infoBadge(Icons.layers_outlined, '${book.categories.length} categories'),
                                infoBadge(Icons.people_outline, '${book.authors.length} authors'),
                                infoBadge(Icons.star_border_rounded, '${(book.averageRating ?? 0).toStringAsFixed(1)} rating'),
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
                                        const SnackBar(content: Text('Added to cart!')),
                                      );
                                    },
                                    icon: const Icon(Icons.add_shopping_cart),
                                    label: const Text('Add to cart'),
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
                                    child: const Text('Buy now', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                            // Description Section
                            Text(
                              'About this book',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Builder(builder: (_) {
                              final description = (book.description ?? '').trim();
                              final showMore = description.length > 320;
                              final display = description.isNotEmpty ? description : 'No description yet.';

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: Text(
                                      display,
                                      maxLines: _showFullDescription ? null : 8,
                                      overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            height: 1.6,
                                            color: Colors.white.withValues(alpha: 0.86),
                                          ),
                                    ),
                                  ),
                                  if (showMore)
                                    TextButton.icon(
                                      onPressed: () => setState(() => _showFullDescription = !_showFullDescription),
                                      icon: Icon(_showFullDescription ? Icons.expand_less : Icons.expand_more),
                                      label: Text(_showFullDescription ? 'Show less' : 'Read more'),
                                      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      // Related Books
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Related books',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: _loadingRelated
                            ? const Center(child: CircularProgressIndicator())
                            : _relatedBooks.isEmpty
                                ? const Center(child: Text('No related books'))
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
  bool _showFullContent = false;

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
        const SnackBar(content: Text('Please enter name, email, and comment content')),
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
        const SnackBar(content: Text('Comment submitted, pending approval')), 
      );
      await _loadComments();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit comment: $e')),
      );
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  String _initials(String value) {
    final text = value.trim();
    if (text.isEmpty) return 'B';
    return text[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final publishedAtText = post?.publishedAt != null ? DateFormat('dd/MM/yyyy').format(post!.publishedAt!) : null;
    final contentDisplay = (post?.excerpt.trim() ?? '').isNotEmpty ? post!.excerpt.trim() : 'Content is being updated.';
    final showMoreContent = contentDisplay.length > 320;

    return Scaffold(
      appBar: AppBar(title: const Text('Post details')),
      body: _loading && post == null
          ? const Center(child: CircularProgressIndicator())
          : post == null
              ? const Center(child: Text('No data'))
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
                                    Text('${post.viewCount ?? 0} views'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (post.tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: post.tags.map((e) => Chip(label: Text('#$e'))).toList(growable: false),
                              ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
                                        child: Text(
                                          _initials(post.title),
                                          style: const TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Readify post',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                            if (publishedAtText != null)
                                              Text(
                                                publishedAtText,
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.more_horiz),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: Text(
                                      contentDisplay,
                                      maxLines: _showFullContent ? null : 8,
                                      overflow: _showFullContent ? TextOverflow.visible : TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
                                    ),
                                  ),
                                  if (showMoreContent)
                                    TextButton.icon(
                                      onPressed: () => setState(() => _showFullContent = !_showFullContent),
                                      icon: Icon(_showFullContent ? Icons.expand_less : Icons.expand_more),
                                      label: Text(_showFullContent ? 'Show less' : 'Read more'),
                                      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                                    ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: Text('${post.viewCount ?? 0} views', style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                                        label: const Text('Like'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.mode_comment_outlined, size: 18),
                                        label: const Text('Comment'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.share_outlined, size: 18),
                                        label: const Text('Share'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Comments',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                        child: Text(
                                          _initials(_commentNameController.text.isNotEmpty ? _commentNameController.text : 'You'),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TextField(
                                              controller: _commentContentController,
                                              minLines: 3,
                                              maxLines: 5,
                                              decoration: const InputDecoration(
                                                hintText: 'Share your thoughts...',
                                                border: OutlineInputBorder(),
                                                alignLabelWithHint: true,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _commentNameController,
                                                    decoration: const InputDecoration(
                                                      labelText: 'Your name',
                                                      border: OutlineInputBorder(),
                                                      isDense: true,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: TextField(
                                                    controller: _commentEmailController,
                                                    keyboardType: TextInputType.emailAddress,
                                                    decoration: const InputDecoration(
                                                      labelText: 'Email',
                                                      border: OutlineInputBorder(),
                                                      isDense: true,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: FilledButton.icon(
                                                onPressed: _submittingComment ? null : _submitComment,
                                                icon: _submittingComment
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      )
                                                    : const Icon(Icons.send_outlined),
                                                label: Text(_submittingComment ? 'Submitting...' : 'Post comment'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
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
                                child: const Text('No comments yet'),
                              )
                            else
                              Column(
                                children: _comments
                                    .map(
                                      (comment) => Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                                              child: Text(
                                                _initials(comment.authorName),
                                                style: const TextStyle(fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.03),
                                                  borderRadius: BorderRadius.circular(12),
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
                                            ),
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
                          'Related posts',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 238,
                        child: _loadingRelated
                            ? const Center(child: CircularProgressIndicator())
                            : _relatedPosts.isEmpty
                                ? const Center(child: Text('No related posts'))
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
