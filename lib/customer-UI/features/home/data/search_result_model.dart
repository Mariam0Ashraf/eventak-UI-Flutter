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
    List<String> categoriesList = [];

    if (type == SearchResultType.package) {
      final cats = json['categories'] as List<dynamic>? ?? [];
      categoriesList = cats.map((e) => e['name'].toString()).toList();
    } else {
      final cats = json['categories'] as List<dynamic>? ?? [];
      categoriesList = cats.map((e) => e.toString()).toList();
    }

    return SearchResult(
      id: json['id'] ?? 0,
      title: json['name'] ?? 'Unknown',
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      image: json['thumbnail_url'], 
      type: type,
      categories: categoriesList,
    );
  }
}
