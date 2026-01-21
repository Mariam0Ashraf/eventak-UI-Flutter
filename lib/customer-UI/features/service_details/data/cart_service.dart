import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';

class CartService {
  Future<void> addToCart({
    required int bookableId,
    required String eventDate,
    String? startTime,
    String? endTime,
    int? capacity,
    int? areaId,
    String? notes,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token')?.replaceAll('"', '');

    final Map<String, dynamic> body = {
      "bookable_id": bookableId,
      "bookable_type": "service",
      "event_date": eventDate,
    };

    if (capacity != null) body["capacity"] = capacity;
    if (startTime != null) body["start_time"] = startTime;
    if (endTime != null) body["end_time"] = endTime;
    if (areaId != null) body["area_id"] = areaId;
    if (notes != null && notes.isNotEmpty) body["notes"] = notes;

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add to cart');
    }
  }
}