import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';

class CartResponse {
  final List<CartItem> items;
  final int itemsCount;
  final double total;

  CartResponse({
    required this.items,
    required this.itemsCount,
    required this.total,
  });
}
