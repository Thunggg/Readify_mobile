import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../book/screens/book_search_filter_screen.dart';
import '../../book/services/book_filter_storage_service.dart';
import '../../auth/login/login_screen.dart';
import '../models/home_models.dart';
import '../providers/home_provider.dart';
import '../services/home_service.dart';
import '../../cart/cart_screen.dart';
import '../../cart/cart_service.dart';
import '../../order/order_screen.dart';

part 'home_header_part.dart';
part 'home_tabs_part.dart';
part 'home_sections_part.dart';
part 'home_details_part.dart';
part 'home_blog_filter_part.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeProvider _provider = HomeProvider();
  final NumberFormat _currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _provider.loadHome();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_tabIndex == 1) {
      _debounce?.cancel();
      _provider.clearSearchSuggestions();
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _provider.searchGlobal(value);
    });
  }

  void _onHeaderSearchTap() {
    final keyword = _searchController.text.trim();
    if (_tabIndex == 1) {
      _openBlogSearchFilterPage(initialKeyword: keyword);
      return;
    }

    _openBookSearchFilterPage(initialKeyword: keyword);
  }

  Future<void> _openBookSearchFilterPage({String? initialKeyword}) async {
    // Navigate to Search Filter page and wait for it to close
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookSearchFilterScreen(
          categories: _provider.bookCategories,
          currency: _currency,
          initialKeyword: initialKeyword,
          onOpenDetail: (book) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    BookDetailScreen(bookId: book.id, initialBook: book),
              ),
            );
          },
          onToggleFavoriteBook: _provider.toggleFavoriteBook,
          isBookFavorited: _provider.isBookFavorited,
        ),
      ),
    );

    // Khi trở về từ màn search/filter: xóa ô search ngoài header và reset bộ lọc về mặc định.
    await BookFilterStorageService().clearState();
    if (mounted) {
      setState(() {
        _searchController.clear();
      });
    }
    _provider.clearSearchSuggestions();
  }

  Future<void> _openBlogSearchFilterPage({String? initialKeyword}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlogSearchFilterScreen(
          categories: _provider.blogCategories,
          initialKeyword: initialKeyword,
          onOpenDetail: (post) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    BlogDetailScreen(slug: post.slug, initialPost: post),
              ),
            );
          },
          onToggleFavoriteBlog: _provider.toggleFavoriteBlog,
          isBlogFavorited: _provider.isBlogFavorited,
        ),
      ),
    );
  }

  void _handleSearchTap(HomeSearchSuggestion item) {
    _searchController.clear();
    _provider.clearSearchSuggestions();

    if (item.type == 'book' && item.book != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              BookDetailScreen(bookId: item.book!.id, initialBook: item.book!),
        ),
      );
      return;
    }

    if (item.type == 'blog' && item.blog != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              BlogDetailScreen(slug: item.blog!.slug, initialPost: item.blog!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider,
          builder: (context, child) {
            return Column(
              children: [
                _TopHeader(
                  userName: _provider.userName,
                  unreadNotifications: _provider.unreadNotifications,
                  searchController: _searchController,
                  searching: _provider.searching,
                  suggestions: _provider.searchSuggestions,
                  onLogoTap: () => setState(() => _tabIndex = 0),
                  onSearchTap: _onHeaderSearchTap,
                  onSearchChanged: _onSearchChanged,
                  onSelectSuggestion: _handleSearchTap,
                  onProfileMenuTap: (value) {
                    if (value == 'profile') {
                      setState(() => _tabIndex = 2);
                      return;
                    }
                    if (value == 'logout') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
                if (!isMobile)
                  _DesktopTabBar(
                    currentIndex: _tabIndex,
                    onTap: (value) => setState(() => _tabIndex = value),
                  ),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      _HomeTab(
                        provider: _provider,
                        currency: _currency,
                        onOpenBooksTab: () {},
                        onOpenBlogsTab: () => setState(() => _tabIndex = 1),
                        onOpenBookDetail: (book) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(
                                bookId: book.id,
                                initialBook: book,
                              ),
                            ),
                          );
                        },
                        onOpenBlogDetail: (post) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlogDetailScreen(
                                slug: post.slug,
                                initialPost: post,
                              ),
                            ),
                          );
                        },
                        onToggleFavoriteBook: _provider.toggleFavoriteBook,
                        onToggleFavoriteBlog: _provider.toggleFavoriteBlog,
                        isBookFavorited: _provider.isBookFavorited,
                        isBlogFavorited: _provider.isBlogFavorited,
                      ),
                      _BlogsTab(
                        provider: _provider,
                        onOpenDetail: (post) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BlogDetailScreen(
                                slug: post.slug,
                                initialPost: post,
                              ),
                            ),
                          );
                        },
                        onToggleFavoriteBlog: _provider.toggleFavoriteBlog,
                        isBlogFavorited: _provider.isBlogFavorited,
                      ),
                      _ProfileTab(provider: _provider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (value) =>
                  setState(() => _tabIndex = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.article_outlined),
                  selectedIcon: Icon(Icons.article),
                  label: 'Blog',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Cá nhân',
                ),
              ],
            )
          : null,
    );
  }
}
