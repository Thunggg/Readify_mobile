import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_error.dart';
import '../../home/models/home_models.dart';
import '../../home/services/home_service.dart';
import '../models/book_filter_result.dart';
import '../models/book_filter_state.dart';
import '../services/book_filter_storage_service.dart';
import '../widgets/book_filter_bottom_sheet.dart';
import '../widgets/book_result_card.dart';

class BookSearchFilterScreen extends StatefulWidget {
  const BookSearchFilterScreen({
    super.key,
    required this.categories,
    required this.currency,
    this.initialKeyword,
    required this.onOpenDetail,
    required this.onToggleFavoriteBook,
    required this.isBookFavorited,
  });

  final List<HomeCategory> categories;
  final NumberFormat currency;
  final String? initialKeyword;
  final ValueChanged<HomeBook> onOpenDetail;
  final ValueChanged<HomeBook> onToggleFavoriteBook;
  final bool Function(String id) isBookFavorited;

  @override
  State<BookSearchFilterScreen> createState() => _BookSearchFilterScreenState();
}

class _BookSearchFilterScreenState extends State<BookSearchFilterScreen> {
  static const _sortOptions = <Map<String, String>>[
    {'value': 'newest', 'label': 'Newest'},
    {'value': 'price_asc', 'label': 'Price: Low to high'},
    {'value': 'price_desc', 'label': 'Price: High to low'},
    {'value': 'rating_desc', 'label': 'Top rated'},
  ];

  final HomeService _bookService = HomeService();
  final BookFilterStorageService _storageService = BookFilterStorageService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  final List<HomeBook> _books = [];

  int _page = 1;
  static const int _limit = 12;
  bool _initializing = true;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasNext = true;
  String? _errorMessage;

  bool _gridView = true;
  BookFilterState _filterState = const BookFilterState();

  int get _activeFilterCount {
    var count = 0;
    if (_filterState.categoryIds.isNotEmpty) count += 1;
    if (_filterState.minPrice != null || _filterState.maxPrice != null) count += 1;
    return count;
  }

  bool get _isSearching => _filterState.keyword.trim().isNotEmpty;

  String get _sortLabel {
    final found = _sortOptions.where((e) => e['value'] == _filterState.sort);
    if (found.isEmpty) return 'Newest';
    return found.first['label']!;
  }

  List<HomeCategory> get _effectiveCategories {
    if (widget.categories.isNotEmpty) return widget.categories;
    return const [
      HomeCategory(id: 'novel', name: 'Novel'),
      HomeCategory(id: 'science', name: 'Science'),
      HomeCategory(id: 'economy', name: 'Economy'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _restoreStateAndLoad();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _restoreStateAndLoad() async {
    final storedState = await _storageService.readState();
    
    // If navigated here WITHOUT an initialKeyword, restore previous state (including prior keyword).
    // If an initialKeyword IS provided (even empty after clearing), override keyword with it.
    if (widget.initialKeyword == null) {
      _filterState = storedState;
    } else {
      _filterState = storedState.copyWith(keyword: widget.initialKeyword!.trim());
    }
    
    _searchController.text = _filterState.keyword;

    if (!mounted) return;
    setState(() => _initializing = false);
    await _loadBooks(reset: true);
  }

  Future<void> _persistState() async {
    await _storageService.writeState(_filterState);
  }

  void _rememberSearch(String keyword) {
    final query = keyword.trim();
    if (query.isEmpty) return;

    final nextSearches = <String>[
      query,
      ..._filterState.recentSearches.where((e) => e.toLowerCase() != query.toLowerCase()),
    ].take(8).toList(growable: false);

    _filterState = _filterState.copyWith(recentSearches: nextSearches);
    _persistState();
  }

  Future<void> _loadBooks({required bool reset}) async {
    if (reset) {
      setState(() {
        _errorMessage = null;
        _loading = true;
        _page = 1;
        _hasNext = true;
        _books.clear();
      });
    } else {
      if (_loadingMore || !_hasNext) return;
      setState(() => _loadingMore = true);
    }

    try {
      final result = await _bookService.getBooksPage(
        HomeBookQuery(
          page: _page,
          limit: _limit,
          keyword: _filterState.keyword,
          categoryId: _filterState.categoryIds.length == 1 ? _filterState.categoryIds.first : null,
          minPrice: _filterState.minPrice,
          maxPrice: _filterState.maxPrice,
          sort: _filterState.sort,
        ),
      );

      final keyword = _filterState.keyword.trim().toLowerCase();
      var incoming = keyword.isEmpty
          ? result.items
          : result.items
              .where(
                (book) => book.title.toLowerCase().contains(keyword) || book.authorText.toLowerCase().contains(keyword),
              )
              .toList(growable: false);

      if (_filterState.categoryIds.isNotEmpty) {
        incoming = incoming
            .where(
              (book) => book.categories.any((category) => _filterState.categoryIds.contains(category.id)),
            )
            .toList(growable: false);
      }

      if (!mounted) return;

      setState(() {
        _books.addAll(incoming);
        _hasNext = result.hasNext;
        _page += 1;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is DioException ? prettyDioError(error) : error.toString();
      if (reset) {
        setState(() => _errorMessage = message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 180) {
      _loadBooks(reset: false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _filterState = _filterState.copyWith(keyword: value.trim());
      });
      _rememberSearch(_filterState.keyword);
      _persistState();
      _loadBooks(reset: true);
    });
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
                    trailing: option['value'] == _filterState.sort ? const Icon(Icons.check) : null,
                    onTap: () => Navigator.of(context).pop(option['value']),
                  ),
                )
                .toList(growable: false),
          ),
        );
      },
    );

    if (sort == null || sort == _filterState.sort) return;
    setState(() => _filterState = _filterState.copyWith(sort: sort));
    _persistState();
    _loadBooks(reset: true);
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<BookFilterResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.78,
          child: BookFilterBottomSheet(
            categories: _effectiveCategories,
            selectedCategoryIds: _filterState.categoryIds,
            minPrice: _filterState.minPrice,
            maxPrice: _filterState.maxPrice,
          ),
        );
      },
    );

    if (result == null) return;
    setState(() {
      _filterState = _filterState.copyWith(
        categoryIds: result.categoryIds,
        minPrice: result.minPrice,
        maxPrice: result.maxPrice,
        clearMinPrice: result.minPrice == null,
        clearMaxPrice: result.maxPrice == null,
      );
    });
    _persistState();
    _loadBooks(reset: true);
  }

  void _resetFilters() {
    setState(() {
      _filterState = _filterState.copyWith(
        categoryIds: <String>{},
        clearMinPrice: true,
        clearMaxPrice: true,
      );
    });
    _persistState();
    _loadBooks(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Books')),
        body: _buildSkeleton(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by title or author...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    isDense: true,
                  ),
                ),
                if (!_isSearching && _filterState.recentSearches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _filterState.recentSearches
                          .map(
                            (item) => ActionChip(
                              label: Text(item),
                              onPressed: () {
                                _searchController.text = item;
                                _onSearchChanged(item);
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _openSortSheet,
                  child: Text('$_sortLabel ▼'),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: _openFilterSheet,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.filter_alt_outlined),
                      if (_activeFilterCount > 0)
                        Positioned(
                          right: -10,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '$_activeFilterCount',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: Text('Filters${_activeFilterCount > 0 ? ' ($_activeFilterCount)' : ''}'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _gridView = !_gridView),
                  icon: Icon(_gridView ? Icons.view_list : Icons.grid_view),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      if (_isSearching) return const Center(child: CircularProgressIndicator());
      return _buildSkeleton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 44),
              const SizedBox(height: 10),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              FilledButton(onPressed: () => _loadBooks(reset: true), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.search_off_rounded, size: 56),
          const SizedBox(height: 12),
          const Text('No books found', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Center(
              child: OutlinedButton(
                onPressed: _resetFilters,
                child: const Text('Reset filters'),
              ),
          ),
        ],
      );
    }

    if (_gridView) {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.62,
        ),
        itemCount: _books.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _books.length) {
            return const Center(child: CircularProgressIndicator());
          }
          final book = _books[index];
          return BookResultCard(
            book: book,
            isGrid: true,
            priceText: widget.currency.format(book.basePrice),
            favorited: widget.isBookFavorited(book.id),
            onTap: () => widget.onOpenDetail(book),
            onToggleFavorite: () => widget.onToggleFavoriteBook(book),
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added "${book.title}" to cart')),
              );
            },
          );
        },
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
      itemBuilder: (context, index) {
        if (index >= _books.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final book = _books[index];
        return BookResultCard(
          book: book,
          isGrid: false,
          priceText: widget.currency.format(book.basePrice),
          favorited: widget.isBookFavorited(book.id),
          onTap: () => widget.onOpenDetail(book),
          onToggleFavorite: () => widget.onToggleFavoriteBook(book),
          onAddToCart: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added "${book.title}" to cart')),
            );
          },
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: _books.length + (_loadingMore ? 1 : 0),
    );
  }

  Widget _buildSkeleton() {
    if (_gridView) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.62,
        ),
        itemCount: 10,
        itemBuilder: (context, index) => const BookResultCardSkeleton(isGrid: true),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      itemBuilder: (context, index) => const BookResultCardSkeleton(isGrid: false),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: 8,
    );
  }
}
