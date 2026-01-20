import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_response.dart';

class CartService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token')?.replaceAll('"', '');
  }

  Future<void> addToCart({
    required int bookableId,
    required String eventDate,
    int? capacity,
    String? startTime,
    String? endTime,
    int? areaId,
    String? notes,
  }) async {
    final token = await _getToken();
    final Map<String, dynamic> body = {
      "bookable_id": bookableId,
      "bookable_type": "service",
      "event_date": eventDate,
      if (capacity != null) "capacity": capacity,
      if (startTime != null) "start_time": startTime,
      if (endTime != null) "end_time": endTime,
      if (areaId != null) "area_id": areaId,
      if (notes != null && notes.isNotEmpty) "notes": notes,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Failed to add to cart');
    }
  }

  Future<CartResponse> getCart(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/cart'), headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode != 200) throw Exception('Failed to fetch cart');
    final decoded = jsonDecode(response.body);
    final items = (decoded['data']['items'] as List).map((e) => CartItem.fromJson(e)).toList();
    return CartResponse(items: items, total: decoded['data']['total'].toDouble(), itemsCount: decoded['data']['items_count']);
  }

  Future<void> deleteCartItem(int cartItemId, String token) async {
    await http.delete(Uri.parse('$baseUrl/cart/items/$cartItemId'), headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
  }

  Future<void> clearCart(String token) async {
    await http.delete(Uri.parse('$baseUrl/cart'), headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
  }
}