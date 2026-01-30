import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_model.dart';

class CheckoutService {
  final String baseUrl;

  CheckoutService(this.baseUrl);

  Future<Booking> createBooking({
    required String token,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(decoded['message'] ?? 'Booking failed');
    }

    return Booking.fromJson(decoded['data']);
  }
}
