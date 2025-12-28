import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'review_model.dart';
import 'package:eventak/core/constants/api_constants.dart';

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
  Future<List<Review>> getReviews(int serviceId) async {
    final res = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/reviews?reviewable_type=service&reviewable_id=$serviceId',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    final decoded = json.decode(res.body);
    final List list = decoded['data']?['data'] ?? [];

    return list.map((e) => Review.fromJson(e)).toList();
  }

  //Create review (AUTH REQUIRED)
  Future<void> createReview({
    required int serviceId,
    required int rating,
    required String comment,
  }) async {
    final headers = await _authHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/reviews'),
      headers: headers,
      body: json.encode({
        "reviewable_type": "service",
        "reviewable_id": serviceId,
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
      body: json.encode({
        "rating": rating,
        "comment": comment,
      }),
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
