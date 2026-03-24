class BookFilterState {
  const BookFilterState({
    this.keyword = '',
    this.sort = 'newest',
    this.minPrice,
    this.maxPrice,
    this.categoryIds = const <String>{},
    this.recentSearches = const <String>[],
  });

  final String keyword;
  final String sort;
  final double? minPrice;
  final double? maxPrice;
  final Set<String> categoryIds;
  final List<String> recentSearches;

  BookFilterState copyWith({
    String? keyword,
    String? sort,
    double? minPrice,
    double? maxPrice,
    Set<String>? categoryIds,
    List<String>? recentSearches,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return BookFilterState(
      keyword: keyword ?? this.keyword,
      sort: sort ?? this.sort,
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      categoryIds: categoryIds ?? this.categoryIds,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}
