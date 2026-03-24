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
    {'value': 'newest', 'label': 'Newest'},
    {'value': 'popular', 'label': 'Popular'},
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
    final selectedFilterCount = _selectedTags.length + (_keyword.isNotEmpty ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog - Search & Filter'),
        actions: [
          TextButton(onPressed: _clearFilters, child: const Text('Reset')),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.article_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Results: ${items.length} posts',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (selectedFilterCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('$selectedFilterCount filters'),
                  ),
              ],
            ),
          ),
          if (_keyword.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.search, size: 16),
                  label: Text('Keyword: "$_keyword"'),
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
                        ? const Center(child: Text('No matching posts'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemBuilder: (context, index) {
                              final post = items[index];
                              final published = post.publishedAt != null ? DateFormat('dd/MM/yyyy').format(post.publishedAt!) : '--/--/----';
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
                                  child: SizedBox(
                                    height: 100,
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
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              SizedBox(
                                                height: 24,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '$published • ${post.viewCount ?? 0} views',
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
                                                      onPressed: () => widget.onToggleFavoriteBlog(post),
                                                      iconSize: 20,
                                                      icon: Icon(
                                                        widget.isBlogFavorited(post.id)
                                                            ? Icons.favorite
                                                            : Icons.favorite_border,
                                                        color: Colors.redAccent,
                                                      ),
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
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemCount: items.length,
                          ),
          ),
        ],
      ),
    );
  }
}
