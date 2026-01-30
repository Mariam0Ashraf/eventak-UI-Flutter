enum CartItemType { service, package }

class CartItem {
  final int cartItemId;
  final int bookableId;
  final CartItemType type;

  final String name;
  final String description;
  final String? imageUrl;

  final double price;

  // Booking info
  final String? bookingDate;
  final String? startTime;
  final String? endTime;

  // Capacity 
  int? capacity;
  final int? minCapacity;
  final int? maxCapacity;
  final bool supportsCapacity;

  final Map<String, dynamic> options;

  CartItem({
    required this.cartItemId,
    required this.bookableId,
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.options,
    this.imageUrl,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.capacity,
    this.minCapacity,
    this.maxCapacity,
    required this.supportsCapacity,
  });

  double get totalPrice => price;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final bookable = json['bookable'] ?? {};
    final options = json['options'] ?? {}; 

    final priceValue = json['price'] ?? 0;
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
      price: priceDouble,
      options: options,
      type: (json['bookable_type'] as String).contains('service_package')
          ? CartItemType.package
          : CartItemType.service,
      name: bookable['name'] ?? 'Item',
      description: bookable['description'] ?? '',
      imageUrl: image,

      
      bookingDate: options['event_date'], 
      startTime: options['start_time'],
      endTime: options['end_time'],

      
      capacity: json['capacity'] ?? options['capacity'], 
      minCapacity: bookable['min_capacity'],
      maxCapacity: bookable['max_capacity'],
      supportsCapacity: bookable['supports_capacity'] ?? false,
    );
  }
}
