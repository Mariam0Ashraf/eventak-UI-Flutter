enum CartItemType { service, package }

class CartItem {
  final int cartItemId;
  final int bookableId;
  final CartItemType type;
  final String name;
  final double price;
  int quantity;
  final Map<String, dynamic> options;
  


  CartItem({
    required this.cartItemId,
    required this.bookableId,
    required this.type,
    required this.name,
    required this.price,
    required this.quantity,
    required this.options,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final bookableType = json['bookable_type'] as String;

    return CartItem(
      cartItemId: json['id'],
      bookableId: json['bookable_id'],
      quantity: json['quantity'],
      price: double.parse(json['price']),
      options: json['options'] ?? {},
      type: bookableType.contains('ServicePackage')
          ? CartItemType.package
          : CartItemType.service,
      name: json['bookable']['name'],
    );
  }
}
