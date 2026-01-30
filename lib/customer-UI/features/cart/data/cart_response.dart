import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';

class CartResponse {
  final List<CartItem> items;
  final int itemsCount;
  final double subtotal;
  final double discountAmount;
  final double total;
  final String? promocodeApplied;
  final double pointsDiscount;
  final int pointsRedeemed;
  final int userLoyaltyPoints;

  CartResponse({
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
    this.promocodeApplied,
    required this.pointsDiscount,
    required this.pointsRedeemed, 
    required this.userLoyaltyPoints
  });
}
