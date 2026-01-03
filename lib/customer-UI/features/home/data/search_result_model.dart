enum SearchResultType { service, package }

class SearchResult {
  final int id;
  final String title;
  final double rating;
  final String? image;
  final SearchResultType type;

  SearchResult({
    required this.id,
    required this.title,
    required this.type,
    required this.rating,
    this.image,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json, SearchResultType type) {
    // Safely extract avatar from provider object
    final provider = json['provider'] as Map<String, dynamic>?;
    
    return SearchResult(
      id: json['id'] ?? 0,
      title: json['name'] ?? 'Unknown',
      
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      image: provider != null ? provider['avatar'] : null,
      type: type,
    );
  }
}