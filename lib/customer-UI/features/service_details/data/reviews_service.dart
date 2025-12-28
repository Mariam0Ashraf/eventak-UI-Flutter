import 'dart:convert';
import 'package:http/http.dart' as http;
import 'review_model.dart';
import 'package:eventak/core/constants/api_constants.dart';

class ReviewsService {
  ReviewsService();

  Future<List<Review>> getReviews(int serviceId) async {
    final res = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/reviews?reviewable_type=service&reviewable_id=$serviceId',
      ),
    );

    final decoded = json.decode(res.body);

    final List list = decoded['data']?['data'] ?? [];

    return list.map((e) => Review.fromJson(e)).toList();
  }

  Future<void> createReview({
    required int serviceId,
    required int rating,
    required String comment,
  }) async {
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}/reviews'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "reviewable_type": "service",
        "reviewable_id": serviceId,
        "rating": rating,
        "comment": comment,
      }),
    );
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    await http.put(
      Uri.parse('${ApiConstants.baseUrl}/reviews/$reviewId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"rating": rating, "comment": comment}),
    );
  }

  Future<void> deleteReview(int reviewId) async {
    await http.delete(Uri.parse('${ApiConstants.baseUrl}/reviews/$reviewId'));
  }
}
