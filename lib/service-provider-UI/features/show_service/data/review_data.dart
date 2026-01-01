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

  String? extractUserName() {
    if (json['user'] != null && json['user']['name'] != null) {
      return json['user']['name'].toString();
    }
    return json['user_name']?.toString();
  }

  return ServiceReview(
    id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
    rating: parseRating(json['rating']),
    comment: json['comment']?.toString(),
    userName: extractUserName(),
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
  );
}
}
