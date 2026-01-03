enum SearchResultType { service, package }

class SearchResult {
  final int id;
  final String title;
  final double rating;
  final int reviewsCount;
  final String? image;
  final SearchResultType type;
  final List<String> categories;

  SearchResult({
    required this.id,
    required this.title,
    required this.rating,
    required this.reviewsCount,
    required this.type,
    required this.categories,
    this.image,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json, SearchResultType type) {
    final provider = json['provider'] as Map<String, dynamic>?;

    List<String> categories = [];

    if (type == SearchResultType.package) {
      final items = json['items'] as List<dynamic>? ?? [];
      final set = <String>{};

      for (final item in items) {
        final service = item['service'];
        final category = service?['category_id'];
        if (category != null && category['name'] != null) {
          set.add(category['name']);
        }
      }

      categories = set.toList();
    } else {
      final category = json['category_id'];
      if (category != null && category['name'] != null) {
        categories = [category['name']];
      }
    }

    return SearchResult(
      id: json['id'] ?? 0,
      title: json['name'] ?? 'Unknown',
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      image: provider != null ? provider['avatar'] : null,
      type: type,
      categories: categories,
    );
  }
}
