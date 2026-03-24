class HomeBook {
  const HomeBook({
    required this.id,
    required this.title,
    required this.slug,
    required this.authors,
    required this.basePrice,
    required this.currency,
    this.thumbnailUrl,
    this.averageRating,
    this.description,
    this.categories = const [],
  });

  final String id;
  final String title;
  final String slug;
  final List<String> authors;
  final double basePrice;
  final String currency;
  final String? thumbnailUrl;
  final double? averageRating;
  final String? description;
  final List<HomeCategory> categories;

  String get authorText {
    if (authors.isEmpty) return 'Unknown author';
    return authors.where((e) => e.trim().isNotEmpty).join(', ');
  }

  factory HomeBook.fromJson(Map<String, dynamic> json) {
    final rawAuthors = json['authors'];
    final authors = <String>[];

    if (rawAuthors is List) {
      for (final item in rawAuthors) {
        if (item is Map<String, dynamic>) {
          final name = item['name']?.toString() ?? '';
          if (name.trim().isNotEmpty) authors.add(name.trim());
        } else if (item is String && item.trim().isNotEmpty) {
          authors.add(item.trim());
        }
      }
    }

    final rawCategories = json['categoryIds'];
    final categories = <HomeCategory>[];
    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map<String, dynamic>) {
          categories.add(HomeCategory.fromJson(item));
        } else if (item is String && item.trim().isNotEmpty) {
          categories.add(HomeCategory(id: item.trim(), name: ''));
        }
      }
    }

    return HomeBook(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      authors: authors,
      basePrice: _toDouble(json['basePrice']),
      currency: (json['currency'] ?? 'VND').toString(),
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      averageRating: _toNullableDouble(json['averageRating']),
      description: json['description']?.toString(),
      categories: categories,
    );
  }
}

class HomeBlogPost {
  const HomeBlogPost({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.publishedAt,
    this.featuredImage,
    this.viewCount,
    this.commentCount,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String slug;
  final String excerpt;
  final DateTime? publishedAt;
  final String? featuredImage;
  final int? viewCount;
  final int? commentCount;
  final List<String> tags;

  factory HomeBlogPost.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is List) {
      for (final item in rawTags) {
        final tag = item.toString().trim();
        if (tag.isNotEmpty) tags.add(tag);
      }
    }

    return HomeBlogPost(
      id: (json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      excerpt: (json['excerpt'] ?? '').toString(),
      publishedAt: _toDateTime(json['publishedAt']),
      featuredImage: json['featuredImage']?.toString(),
      viewCount: _toNullableInt(json['viewCount']),
      commentCount: _toNullableInt(json['commentCount']),
      tags: tags,
    );
  }
}

class HomeBlogComment {
  const HomeBlogComment({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String authorEmail;
  final String content;
  final DateTime? createdAt;

  factory HomeBlogComment.fromJson(Map<String, dynamic> json) {
    return HomeBlogComment(
      id: (json['_id'] ?? '').toString(),
      authorName: (json['authorName'] ?? 'Ẩn danh').toString(),
      authorEmail: (json['authorEmail'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: _toDateTime(json['createdAt']),
    );
  }
}

class HomeCategory {
  const HomeCategory({required this.id, required this.name, this.slug});

  final String id;
  final String name;
  final String? slug;

  factory HomeCategory.fromJson(Map<String, dynamic> json) {
    return HomeCategory(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
    );
  }
}

class HomeBannerItem {
  const HomeBannerItem({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.type,
    this.imageUrl,
    this.book,
    this.blog,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String type;
  final String? imageUrl;
  final HomeBook? book;
  final HomeBlogPost? blog;
}

class HomeSearchSuggestion {
  const HomeSearchSuggestion({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.book,
    this.blog,
  });

  final String type; // book | blog
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final HomeBook? book;
  final HomeBlogPost? blog;
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _toNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
