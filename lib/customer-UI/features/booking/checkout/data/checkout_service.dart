import 'dart:convert';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'booking_model.dart';

class CheckoutService {
  
  Future<Booking> createBooking({
    required String token,
    String? notes,
    int? pointsRedeemed,
    String? promocode,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/bookings'), 
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (notes != null) 'notes': notes,
        if (pointsRedeemed != null && pointsRedeemed > 0) 'points_redeemed': pointsRedeemed,
        if (promocode != null) 'promocode': promocode,
      }),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(decoded['message'] ?? 'Booking failed');
    }

    if (decoded['data'] == null) {
      throw Exception('Server error: Booking created but no data returned.');
    }
    return Booking.fromJson(decoded['data']['booking']);

  }
}