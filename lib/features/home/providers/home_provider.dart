import 'package:flutter/foundation.dart';

import '../models/home_models.dart';
import '../services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({HomeService? service}) : _service = service ?? HomeService();

  final HomeService _service;

  bool loading = true;
  String? errorMessage;

  List<HomeBook> featuredBooks = const [];
  List<HomeBook> newestBooks = const [];
  List<HomeBlogPost> newestBlogs = const [];
  List<HomeBlogPost> featuredBlogs = const [];
  List<HomeCategory> bookCategories = const [];
  List<HomeCategory> blogCategories = const [];
  List<String> popularTags = const [];

  List<HomeBannerItem> banners = const [];

  Future<void> loadHome() async {
    loading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _service.getBooks(sort: 'best_selling', limit: 6),
        _service.getBooks(sort: 'newest', limit: 6),
        _service.getBlogs(sortBy: 'newest', limit: 6),
        _service.getBlogs(sortBy: 'popular', limit: 4),
        _service.getBookCategories(limit: 12),
        _service.getBlogCategories(),
      ]);

      featuredBooks = (results[0] as List<HomeBook>);
      newestBooks = (results[1] as List<HomeBook>);
      newestBlogs = (results[2] as List<HomeBlogPost>);
      featuredBlogs = (results[3] as List<HomeBlogPost>);
      bookCategories = (results[4] as List<HomeCategory>);
      blogCategories = (results[5] as List<HomeCategory>);

      final tagCount = <String, int>{};
      for (final post in newestBlogs.followedBy(featuredBlogs)) {
        for (final tag in post.tags) {
          final key = tag.trim();
          if (key.isEmpty) continue;
          tagCount[key] = (tagCount[key] ?? 0) + 1;
        }
      }

      final sortedTags = tagCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      popularTags = sortedTags.take(10).map((e) => e.key).toList(growable: false);

      banners = _buildBanners();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  List<HomeBannerItem> _buildBanners() {
    final out = <HomeBannerItem>[];

    if (featuredBooks.isNotEmpty) {
      final book = featuredBooks.first;
      out.add(
        HomeBannerItem(
          title: 'Sách nổi bật tuần này',
          subtitle: book.title,
          ctaLabel: 'Xem sách',
          type: 'book',
          imageUrl: book.thumbnailUrl,
          book: book,
        ),
      );
    }

    if (featuredBlogs.isNotEmpty) {
      final blog = featuredBlogs.first;
      out.add(
        HomeBannerItem(
          title: 'Bài viết hot',
          subtitle: blog.title,
          ctaLabel: 'Đọc bài viết',
          type: 'blog',
          imageUrl: blog.featuredImage,
          blog: blog,
        ),
      );
    }

    out.add(
      const HomeBannerItem(
        title: 'Ưu đãi dành cho bạn',
        subtitle: 'Khám phá sách mới và nội dung chất lượng mỗi ngày',
        ctaLabel: 'Khám phá ngay',
        type: 'explore',
      ),
    );

    return out;
  }
}
