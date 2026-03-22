import 'package:shared_preferences/shared_preferences.dart';

import '../models/book_filter_state.dart';

class BookFilterStorageService {
  static const _prefsSortKey = 'books.sort';
  static const _prefsKeywordKey = 'books.keyword';
  static const _prefsMinPriceKey = 'books.minPrice';
  static const _prefsMaxPriceKey = 'books.maxPrice';
  static const _prefsCategoryIdsKey = 'books.categoryIds';
  static const _prefsRecentSearchesKey = 'books.recentSearches';

  Future<BookFilterState> readState() async {
    final prefs = await SharedPreferences.getInstance();
    return BookFilterState(
      sort: prefs.getString(_prefsSortKey) ?? 'newest',
      keyword: prefs.getString(_prefsKeywordKey) ?? '',
      minPrice: prefs.getDouble(_prefsMinPriceKey),
      maxPrice: prefs.getDouble(_prefsMaxPriceKey),
      categoryIds: Set<String>.from(prefs.getStringList(_prefsCategoryIdsKey) ?? const <String>[]),
      recentSearches: prefs.getStringList(_prefsRecentSearchesKey) ?? const <String>[],
    );
  }

  Future<void> writeState(BookFilterState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsSortKey, state.sort);
    await prefs.setString(_prefsKeywordKey, state.keyword);

    if (state.minPrice != null) {
      await prefs.setDouble(_prefsMinPriceKey, state.minPrice!);
    } else {
      await prefs.remove(_prefsMinPriceKey);
    }

    if (state.maxPrice != null) {
      await prefs.setDouble(_prefsMaxPriceKey, state.maxPrice!);
    } else {
      await prefs.remove(_prefsMaxPriceKey);
    }

    await prefs.setStringList(_prefsCategoryIdsKey, state.categoryIds.toList(growable: false));
    await prefs.setStringList(_prefsRecentSearchesKey, state.recentSearches);
  }
}
