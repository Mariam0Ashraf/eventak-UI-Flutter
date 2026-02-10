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
  Future<ProviderBooking> fetchBookingDetails(int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.replaceAll('"', '');

    final uri = Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProviderBooking.fromJson(data['data']);
    } else {
      throw Exception('Failed to load booking details');
    }
  }
  Future<void> cancelBookingItem({
  required int bookingId,
  required int itemId,
  required String reason,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');

  final uri = Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/items/$itemId/cancel');

  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode({"reason": reason}),
  );

  final data = json.decode(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    return; 
  } else {
    final String errorMessage = data['message'] ?? "An error occurred";
    throw errorMessage; 
  }
}
Future<Map<String, dynamic>> fetchRefundQuote(int bookingId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');
  final uri = Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/refund-quote');

  final response = await http.get(uri, headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });

  final data = json.decode(response.body);
  if (response.statusCode == 200 && data['success'] == true) {
    final quoteData = data['data'];
    return {
      'can_refund': quoteData['can_refund'] ?? false,
      'refund_percentage': quoteData['refund_percentage'] ?? 0,
      'refund_amount': quoteData['refund_amount'] ?? 0,
      'original_amount': quoteData['original_amount'] ?? "0.00",
    };
  } else {
    throw data['message'] ?? "Could not retrieve refund quote";
  }
}
Future<void> cancelFullBooking(int bookingId, String reason) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token')?.replaceAll('"', '');
  final uri = Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/cancel');

  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode({"reason": reason}),
  );

  final data = json.decode(response.body);
  if (response.statusCode != 200 && response.statusCode != 201) {
    throw data['message'] ?? "Cancellation failed";
  }
}
}