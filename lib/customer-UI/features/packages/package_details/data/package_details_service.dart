import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';

class PackageDetailsService {
  Future<Map<String, dynamic>> getPackage(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/packages/$id'),
    );

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else {
      throw Exception('Failed to load package');
    }
  }

  Future<void> addToCart({
    required int packageId,
    required String eventDate,
    String? startTime,
    String? endTime,
    int? capacity,
    int? areaId,
    String? notes,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token')?.replaceAll('"', '');

    if (token == null) throw Exception('Authentication token not found');

    final Map<String, dynamic> body = {
      "bookable_id": packageId,
      "bookable_type": "service_package",
      "event_date": eventDate,
    };

    if (startTime != null) body["start_time"] = startTime;
    if (endTime != null) body["end_time"] = endTime;
    if (capacity != null) body["capacity"] = capacity;
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
      throw Exception(errorData['message'] ?? 'Failed to add package to cart');
    }
  }
}