class BookFilterResult {
  const BookFilterResult({
    required this.categoryIds,
    this.minPrice,
    this.maxPrice,
  });

  final Set<String> categoryIds;
  final double? minPrice;
  final double? maxPrice;
}
