import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_service.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service;
  double _subtotal = 0;
  double _discount = 0;
  String? _appliedPromo;

  double get subtotal => _subtotal;
  double get discount => _discount;
  String? get appliedPromo => _appliedPromo;
  int get itemCount => _items.length;

  
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

  Future<void> loadCart({String? promocode, bool forceRefresh = false}) async {
    if (_items.isNotEmpty && promocode == null && !forceRefresh) {
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await _service.getCart(token, promocode: promocode);
      _items = response.items;
      _total = response.total;
      _subtotal = response.subtotal;
      _discount = response.discountAmount;
      _appliedPromo = response.promocodeApplied;
    } catch (e) {
      debugPrint("Load Cart Error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCart() async {
    await loadCart(forceRefresh: true);
  }
  
  Future<void> applyPromocode(String code) async {
    await loadCart(promocode: code);
  }


  Future<void> updateCartItemFull({
    required int cartItemId,
    String? eventDate,
    String? startTime,
    String? endTime,
    int? capacity,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) return;

    await _service.updateCartItem(
      cartItemId: cartItemId,
      token: token,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      capacity: capacity,
      notes: notes,
    );

    await loadCart(); 
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