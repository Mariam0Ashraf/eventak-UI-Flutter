enum CartItemType { service, package }

class CartItem {
  final int cartItemId;
  final int bookableId;
  final CartItemType type;
  final String name;
  final String description;
  final String? imageUrl;
  final double price;
  int quantity;
  final Map<String, dynamic> options;

  CartItem({
    required this.cartItemId,
    required this.bookableId,
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.options,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final bookable = json['bookable'] ?? {};

    // Price parsing (int or string)
    final priceValue = json['price'] ?? bookable['base_price'] ?? 0;
    final double priceDouble = priceValue is int
        ? priceValue.toDouble()
        : double.tryParse(priceValue.toString()) ?? 0.0;

    
    final String? image = bookable['thumbnail_url'] ??
        (bookable['media'] != null && (bookable['media'] as List).isNotEmpty
            ? (bookable['media'] as List).first['original_url']
            : null);

    return CartItem(
      cartItemId: json['id'],
      bookableId: json['bookable_id'],
      quantity: json['quantity'] ?? 1,
      price: priceDouble,
      options: json['options'] ?? {},
      type: (json['bookable_type'] as String).contains('ServicePackage')
          ? CartItemType.package
          : CartItemType.service,
      name: bookable['name'] ?? 'Item',
      description: bookable['description'] ?? '',
      imageUrl: image,
    );
  }


}
