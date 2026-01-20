import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_service.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service;

  
  CartProvider(this._service);

  List<CartItem> _items = [];
  double _total = 0;
  bool _loading = false;

  List<CartItem> get items => _items;
  double get total => _total;
  bool get isLoading => _loading;
  bool get isEmpty => _items.isEmpty;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> loadCart() async {
    _loading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await _service.getCart(token);
      _items = response.items.cast<CartItem>();
      _total = response.total;
    } catch (e) {
      debugPrint("Load Cart Error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateItemQuantity(CartItem item, int qty) async {
    final token = await _getToken();
    if (token == null) return;

    await _service.updateCartItem(
      cartItemId: item.cartItemId,
      quantity: qty,
      token: token,
    );
    item.quantity = qty;
    _recalculateTotal();
    notifyListeners();
  }

  Future<void> removeItem(CartItem item) async {
    final token = await _getToken();
    if (token == null) return;

    await _service.deleteCartItem(item.cartItemId, token);
    _items.remove(item);
    _recalculateTotal();
    notifyListeners();
  }

  Future<void> clearCart() async {
    final token = await _getToken();
    if (token == null) return;

    await _service.clearCart(token);
    _items.clear();
    _total = 0;
    notifyListeners();
  }
  
  void _recalculateTotal() {
    _total = _items.fold(0, (sum, e) => sum + e.totalPrice);
  }
}