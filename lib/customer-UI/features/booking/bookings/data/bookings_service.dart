import 'dart:convert';
import 'package:eventak/customer-UI/features/booking/checkout/data/booking_model.dart';
import 'package:http/http.dart' as http;
import 'package:eventak/core/constants/api_constants.dart';

class BookingsService {
  final String _baseUrl = ApiConstants.baseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Get all user bookings
  Future<List<Booking>> getUserBookings(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings'),
      headers: _headers(token),
    );

    final decoded = json.decode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      final List data = decoded['data'] ?? [];
      return data.map((e) => Booking.fromJson(e)).toList();
    } else {
      throw Exception(decoded['message'] ?? 'Failed to load bookings');
    }
  }

  ///Get booking by ID
  Future<Booking> getBookingById({
    required int bookingId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/$bookingId'),
      headers: _headers(token),
    );

    final decoded = json.decode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return Booking.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to load booking');
    }
  }

  ///Cancel booking
  Future<Booking> cancelBooking({
    required int bookingId,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings/$bookingId/cancel'),
      headers: _headers(token),
    );

    final decoded = json.decode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      return Booking.fromJson(decoded['data']);
    } else {
      throw Exception(decoded['message'] ?? 'Failed to cancel booking');
    }
  }
}
