enum SearchResultType { service, package }

class SearchResult {
  final int id;
  final String title;
  final double rating;
  final int reviewsCount;
  final String? location;
  final String? image;
  final SearchResultType type;
  final List<String> categories;

  SearchResult({
    required this.id,
    required this.title,
    required this.rating,
    required this.reviewsCount,
    this.location,
    required this.type,
    required this.categories,
    this.image,
  });

  factory SearchResult.fromJson(
    Map<String, dynamic> json,
    SearchResultType type,
  ) {
    final provider = json['provider'] as Map<String, dynamic>?;

    // ✅ categories from backend: "categories": [{id,name,...}, ...]
    final cats = <String>[];
    final rawCats = json['categories'];

    if (rawCats is List) {
      for (final c in rawCats) {
        if (c is String) {
          cats.add(c);
        } else if (c is Map && c['name'] != null) {
          cats.add(c['name'].toString());
        }
      }
    }

    // Fallbacks لو endpoint قديم
    if (cats.isEmpty) {
      final category = json['category_id'];
      if (category is Map && category['name'] != null) {
        cats.add(category['name'].toString());
      }
    }

    final location =
        json['location']?.toString() ??
        json['address']?.toString() ??
        provider?['location']?.toString() ??
        provider?['address']?.toString();

    final image =
        (provider?['avatar'] ??
                json['thumbnail'] ??
                json['image'] ??
                json['image_url'])
            ?.toString();

    return SearchResult(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['name']?.toString() ?? 'Unknown',
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      location: location,
      image: image,
      type: type,
      categories: cats,
    );
  }
}
