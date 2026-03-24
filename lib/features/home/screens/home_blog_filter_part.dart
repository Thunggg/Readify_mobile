part of 'home_screen.dart';

class BlogSearchFilterScreen extends StatefulWidget {
  const BlogSearchFilterScreen({
    super.key,
    required this.categories,
    this.initialKeyword,
    required this.onOpenDetail,
    required this.onToggleFavoriteBlog,
    required this.isBlogFavorited,
  });

  final List<HomeCategory> categories;
  final String? initialKeyword;
  final ValueChanged<HomeBlogPost> onOpenDetail;
  final ValueChanged<HomeBlogPost> onToggleFavoriteBlog;
  final bool Function(String id) isBlogFavorited;

  @override
  State<BlogSearchFilterScreen> createState() => _BlogSearchFilterScreenState();
}

class _BlogSearchFilterScreenState extends State<BlogSearchFilterScreen> {
  static const _sortOptions = <Map<String, String>>[
    {'value': 'newest', 'label': 'Mới nhất'},
    {'value': 'popular', 'label': 'Phổ biến'},
  ];

  final HomeService _service = HomeService();
  String _keyword = '';

  bool _loading = true;
  String? _errorMessage;
  String _sort = 'newest';
  Set<String> _selectedTags = <String>{};
  List<HomeBlogPost> _allPosts = const [];

  List<HomeBlogPost> get _visiblePosts {
    var items = _allPosts;

    final keyword = _keyword.trim().toLowerCase();
    if (keyword.isNotEmpty) {
      items = items
          .where(
            (post) =>
                post.title.toLowerCase().contains(keyword) ||
                post.excerpt.toLowerCase().contains(keyword) ||
                post.tags.any((tag) => tag.toLowerCase().contains(keyword)),
          )
          .toList(growable: false);
    }

    if (_selectedTags.isNotEmpty) {
      items = items
          .where((post) => post.tags.any((tag) => _selectedTags.contains(tag.toLowerCase())))
          .toList(growable: false);
    }

    return items;
  }

  List<String> get _availableTags {
    final counter = <String, int>{};
    for (final post in _allPosts) {
      for (final tag in post.tags) {
        final normalized = tag.trim();
        if (normalized.isEmpty) continue;
        counter[normalized] = (counter[normalized] ?? 0) + 1;
      }
    }

    final sorted = counter.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });

    return sorted.take(14).map((e) => e.key).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _keyword = widget.initialKeyword?.trim() ?? '';
    _loadBlogs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getBlogs(sortBy: _sort, limit: 60);
      if (!mounted) return;
      setState(() {
        _allPosts = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _openSortSheet() async {
    final sort = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _sortOptions
                .map(
                  (option) => ListTile(
                    title: Text(option['label']!),
                    trailing: option['value'] == _sort ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(option['value']),
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );

    if (sort == null || sort == _sort) return;
    setState(() => _sort = sort);
    _loadBlogs();
  }

  void _toggleTag(String tag) {
    final normalized = tag.toLowerCase();
    setState(() {
      if (_selectedTags.contains(normalized)) {
        _selectedTags.remove(normalized);
      } else {
        _selectedTags.add(normalized);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _sort = 'newest';
      _selectedTags.clear();
    });
    _loadBlogs();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visiblePosts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog - Tìm kiếm & lọc'),
        actions: [
          TextButton(onPressed: _clearFilters, child: const Text('Đặt lại')),
        ],
      ),
      body: Column(
        children: [
          if (_keyword.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.search, size: 16),
                  label: Text('Từ khóa: "$_keyword"'),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _openSortSheet,
                  icon: const Icon(Icons.swap_vert),
                  label: Text(_sortOptions.firstWhere((e) => e['value'] == _sort)['label']!),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _availableTags
                          .map(
                            (tag) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: _selectedTags.contains(tag.toLowerCase()),
                                label: Text('#$tag'),
                                onSelected: (_) => _toggleTag(tag),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : items.isEmpty
                        ? const Center(child: Text('Không có bài viết phù hợp'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemBuilder: (context, index) {
                              final post = items[index];
                              return InkWell(
                                onTap: () => widget.onOpenDetail(post),
                                borderRadius: BorderRadius.circular(14),
                                child: Ink(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 92,
                                        height: 92,
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
                                            Text(
                                              post.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              post.excerpt,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                if (post.publishedAt != null)
                                                  Text(
                                                    DateFormat('dd/MM/yyyy').format(post.publishedAt!),
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                const SizedBox(width: 10),
                                                if ((post.viewCount ?? 0) > 0)
                                                  Text(
                                                    '${post.viewCount} lượt xem',
                                                    style: Theme.of(context).textTheme.bodySmall,
                                                  ),
                                                const Spacer(),
                                                IconButton(
                                                  visualDensity: VisualDensity.compact,
                                                  onPressed: () => widget.onToggleFavoriteBlog(post),
                                                  icon: Icon(
                                                    widget.isBlogFavorited(post.id)
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemCount: items.length,
                          ),
          ),
        ],
      ),
    );
  }
}
