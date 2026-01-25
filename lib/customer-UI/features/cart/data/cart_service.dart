import 'dart:convert';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_response.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl;

  CartService(this.baseUrl);

  Future<CartResponse> getCart(String token, {String? promocode}) async {
  final uri = Uri.parse('$baseUrl/cart').replace(
    queryParameters: promocode != null ? {'promocode': promocode} : null,
  );

  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  final decoded = jsonDecode(response.body);
  if (response.statusCode != 200) {
    throw Exception(decoded['message'] ?? 'Failed to fetch cart');
  }

  final data = decoded['data'];
  final pricing = data['pricing'];

  final items = (data['items'] as List)
      .map((e) => CartItem.fromJson(e))
      .toList();

  return CartResponse(
    items: items,
    itemsCount: data['items_count'],
    subtotal: (pricing['subtotal'] ?? 0).toDouble(),
    discountAmount: (pricing['discountAmount'] ?? 0).toDouble(),
    total: (pricing['total'] ?? 0).toDouble(),
    promocodeApplied: pricing['promocodeApplied'],
  );
}
  
  Future<void> updateCartItem({
    required int cartItemId,
    required String token,
    String? eventDate,
    String? startTime,
    String? endTime,
    int? capacity,
    String? notes,
    int? areaId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/items/$cartItemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (eventDate != null) 'event_date': eventDate,
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
        if (capacity != null) 'capacity': capacity,
        if (notes != null) 'notes': notes,
        if (areaId != null) 'area_id': areaId,
      }),
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Failed to update item');
    }
  }


  Future<void> deleteCartItem(int cartItemId, String token) async {
    await http.delete(
      Uri.parse('$baseUrl/cart/items/$cartItemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<void> clearCart(String token) async {
    await http.delete(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
}
