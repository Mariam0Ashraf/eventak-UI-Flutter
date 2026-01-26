import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'review_model.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/review_response.dart';

class ReviewsService {
  ReviewsService();

  // Helper to get auth headers
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get reviews
  Future<ReviewsResponse> getReviews({
  required int reviewableId,
  required String reviewableType, 
  int page = 1,
}) async {
  final headers = await _authHeaders();

  final res = await http.get(
    Uri.parse(
      '${ApiConstants.baseUrl}/reviews'
      '?reviewable_type=$reviewableType' 
      '&reviewable_id=$reviewableId'
      '&page=$page',
    ),
    headers: headers,
  );

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }

  final decoded = json.decode(res.body);
  final data = decoded['data'];

  final myReviewJson = data['my_review'];
  final Review? myReview =
      myReviewJson != null ? Review.fromJson(myReviewJson) : null;

  final List list = data['all_reviews']['data'];

  return ReviewsResponse(
    myReview: myReview,
    reviews: list.map((e) => Review.fromJson(e)).toList(),
    currentPage: data['all_reviews']['meta']['current_page'],
    lastPage: data['all_reviews']['meta']['last_page'],
  );
}



  //Create review (AUTH REQUIRED)
Future<void> createReview({
  required int reviewableId,
  required String reviewableType, 
  required int rating,
  required String comment,
}) async {
  final headers = await _authHeaders();

  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/reviews'),
    headers: headers,
    body: json.encode({
      "reviewable_type": reviewableType,
      "reviewable_id": reviewableId,
      "rating": rating,
      "comment": comment,
    }),
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    throw Exception(response.body);
  }
}


  //Update review (AUTH REQUIRED)
  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    final headers = await _authHeaders();

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/reviews/$reviewId'),
      headers: headers,
      body: json.encode({"rating": rating, "comment": comment}),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  // Delete review (AUTH REQUIRED)
  Future<void> deleteReview(int reviewId) async {
    final headers = await _authHeaders();

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/reviews/$reviewId'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}
