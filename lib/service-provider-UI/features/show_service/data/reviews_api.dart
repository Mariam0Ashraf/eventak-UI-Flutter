import 'dart:async';
import 'dart:convert';

import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/review_data.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReviewsApi {
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  ///GET {{base_url}}/reviews?reviewable_type=service&reviewable_id=:id
  Future<List<ServiceReview>> getServiceReviews(int serviceId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reviews').replace(
      queryParameters: {
        'reviewable_type': 'service',
        'reviewable_id': serviceId.toString(),
      },
    );

    final response = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      dynamic data = decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        data = decoded['data'];
      }

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => ServiceReview.fromJson(e))
            .toList();
      }

      throw Exception('Unexpected reviews response shape');
    }

    throw Exception(
      'Failed to load reviews: ${response.statusCode} - ${response.body}',
    );
  }

  ///PUT {{base_url}}/reviews/:id

  Future<ServiceReview> updateReview({
    required int id,
    required double rating,
    String? comment,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reviews/$id');

    final body = jsonEncode({
      "rating": rating, //not sure int or double
      "comment": comment ?? "",
    });

    final response = await http
        .put(uri, headers: await _headers(), body: body)
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      dynamic data = decoded;
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        data = decoded['data'];
      }

      if (data is Map<String, dynamic>) {
        return ServiceReview.fromJson(data);
      }

      throw Exception('Unexpected update review response shape');
    }

    throw Exception(
      'Failed to update review: ${response.statusCode} - ${response.body}',
    );
  }

  // DELETE {{base_url}}/reviews/:id
  Future<void> deleteReview(int id) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/reviews/$id');

    final response = await http
        .delete(uri, headers: await _headers())
        .timeout(_timeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to delete review: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Dummy Data
  Future<List<ServiceReview>> dummyReviews(int serviceId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return [
      ServiceReview(
        id: 1,
        rating: 4.5,
        comment: 'Amazing service!',
        userName: 'Doha',
      ),
      ServiceReview(
        id: 2,
        rating: 3.0,
        comment: 'Good but can be better',
        userName: 'Mariam',
      ),
      ServiceReview(id: 3, rating: 5.0, comment: 'Perfect', userName: 'Sara'),
    ];
  }
}
