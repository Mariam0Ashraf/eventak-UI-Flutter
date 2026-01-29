import 'dart:convert';
import 'package:eventak/service-provider-UI/features/my_bookings/data/provider_booking_model.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderBookingService {
  Future<List<ProviderBooking>> fetchMyBookings({
    String? status,
    String? fromDate,
    String? toDate,
    int perPage = 20, 
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');

    final Map<String, String> queryParams = {
      'per_page': perPage.clamp(1, 100).toString(),
    };

    if (status != null && status != 'all') queryParams['status'] = status;
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;

    final uri = Uri.parse('${ApiConstants.baseUrl}/bookings/provider/my-bookings')
        .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['data'] as List).map((b) => ProviderBooking.fromJson(b)).toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }
}