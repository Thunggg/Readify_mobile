import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../auth/login/login_screen.dart';
import '../models/home_models.dart';
import '../providers/home_provider.dart';
import '../services/home_service.dart';

part 'home_header_part.dart';
part 'home_tabs_part.dart';
part 'home_sections_part.dart';
part 'home_details_part.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeProvider _provider = HomeProvider();
  final NumberFormat _currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _provider.searchGlobal(value);
    });
  }

  void _handleSearchTap(HomeSearchSuggestion item) {
    _searchController.clear();
    _provider.clearSearchSuggestions();

    if (item.type == 'book' && item.book != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: item.book!.id, initialBook: item.book!)),
      );
      return;
    }

    if (item.type == 'blog' && item.blog != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: item.blog!.slug, initialPost: item.blog!)),
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
                  onSearchChanged: _onSearchChanged,
                  onSelectSuggestion: _handleSearchTap,
                  onProfileMenuTap: (value) {
                    if (value == 'profile') {
                      setState(() => _tabIndex = 4);
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
                        onOpenBooksTab: () => setState(() => _tabIndex = 1),
                        onOpenBlogsTab: () => setState(() => _tabIndex = 2),
                        onOpenBookDetail: (book) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id, initialBook: book)),
                          );
                        },
                        onOpenBlogDetail: (post) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: post.slug, initialPost: post)),
                          );
                        },
                        onToggleFavoriteBook: _provider.toggleFavoriteBook,
                        onToggleFavoriteBlog: _provider.toggleFavoriteBlog,
                        isBookFavorited: _provider.isBookFavorited,
                        isBlogFavorited: _provider.isBlogFavorited,
                      ),
                      _BooksTab(
                        provider: _provider,
                        currency: _currency,
                        onOpenDetail: (book) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id, initialBook: book)),
                          );
                        },
                        onToggleFavoriteBook: _provider.toggleFavoriteBook,
                        isBookFavorited: _provider.isBookFavorited,
                      ),
                      _BlogsTab(
                        provider: _provider,
                        onOpenDetail: (post) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: post.slug, initialPost: post)),
                          );
                        },
                        onToggleFavoriteBlog: _provider.toggleFavoriteBlog,
                        isBlogFavorited: _provider.isBlogFavorited,
                      ),
                      _FavoritesTab(
                        provider: _provider,
                        currency: _currency,
                        onOpenBookDetail: (book) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: book.id, initialBook: book)),
                          );
                        },
                        onOpenBlogDetail: (post) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => BlogDetailScreen(slug: post.slug, initialPost: post)),
                          );
                        },
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
              onDestinationSelected: (value) => setState(() => _tabIndex = value),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
                NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Sách'),
                NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'Blog'),
                NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Yêu thích'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Cá nhân'),
              ],
            )
          : null,
    );
  }
}
