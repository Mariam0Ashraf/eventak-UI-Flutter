class ServiceReview {
  final int id;
  final double rating;
  final String? comment;
  final String? userName;
  final DateTime? createdAt;

  ServiceReview({
    required this.id,
    required this.rating,
    this.comment,
    this.userName,
    this.createdAt,
  });

  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    double parseRating(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return ServiceReview(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      rating: parseRating(json['rating'] ?? json['stars']),
      comment: json['comment']?.toString() ?? json['review']?.toString(),
      userName:
          json['user_name']?.toString() ?? json['user']?['name']?.toString(),
      createdAt: parseDate(json['created_at']),
    );
  }
}
