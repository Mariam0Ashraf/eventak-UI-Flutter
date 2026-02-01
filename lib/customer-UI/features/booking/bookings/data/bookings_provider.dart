import 'package:eventak/customer-UI/features/booking/bookings/data/bookings_service.dart';
import 'package:flutter/material.dart';
import 'package:eventak/customer-UI/features/booking/checkout/data/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingsProvider extends ChangeNotifier {
  final BookingsService _service = BookingsService();
  
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> loadBookings() async {
    final token = await _getToken(); 

    if (token == null) {
      _errorMessage = "Authentication required";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await _service.getUserBookings(token);
      debugPrint("Successfully loaded ${_bookings.length} bookings");
    } catch (e, stackTrace) {
      debugPrint("Error type: ${e.runtimeType}");

      debugPrint("Parsing Error: $e");
      debugPrint("Stacktrace: $stackTrace"); 
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(int id) async {
    final token = await _getToken(); 
    if (token == null) return;

    try {
      await _service.cancelBooking(bookingId: id, token: token);
      // Refresh the list automatically 
      await loadBookings(); 
    } catch (e) {
      debugPrint("Cancel failed: $e");
      _errorMessage = "Failed to cancel booking";
      notifyListeners();
    }
  }
}