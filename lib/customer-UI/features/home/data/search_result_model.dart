enum SearchResultType { service, package }

class SearchResult {
  final int id;
  final String title;
  final String? description;
  final double? price;
  final double? rating;
  final int? reviewsCount;
  final String? image;
  final SearchResultType type;

  SearchResult({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.price,
    this.rating,
    this.reviewsCount,
    this.image,
  });
}
