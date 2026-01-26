class Review {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar; 
  final int rating;
  final String comment;
  final String date;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['user']?['id'],
      userName: json['user']?['name'] ?? 'Anonymous',
      userAvatar: json['user']?['avatar'],
      rating: json['rating'],
      comment: json['comment'],
      date: json['created_at'].substring(0, 10),
    );
  }
}
