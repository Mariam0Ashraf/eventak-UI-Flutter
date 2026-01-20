import 'dart:convert';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_response.dart';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl;

  CartService(this.baseUrl);

  Future<CartResponse> getCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'), 
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw Exception(decoded['message'] ?? 'Failed to fetch cart');
    }

    final decoded = jsonDecode(response.body);

    final items = (decoded['data']['items'] as List)
        .map((e) => CartItem.fromJson(e))
        .toList();

    return CartResponse(
      items: items,
      total: decoded['data']['total'].toDouble(),
      itemsCount: decoded['data']['items_count'],
    );
  }

  Future<void> updateCartItem({
    required int cartItemId,
    int? quantity,
    String? notes,
    required String token,
  }) async {
    await http.put(
      Uri.parse('$baseUrl/cart/items/$cartItemId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (quantity != null) 'quantity': quantity,
        if (notes != null) 'notes': notes,
      }),
    );
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
