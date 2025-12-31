class PackageDetails {
  final int id;
  final String name;
  final String? description;
  final double price;
  final List<PackageItem> items;
  final double averageRating;
  final int reviewsCount;

  PackageDetails({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.items,
    required this.averageRating,
    required this.reviewsCount,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    return PackageDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      averageRating: double.tryParse(json['average_rating'].toString()) ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      items: (json['items'] as List?)
          ?.map((i) => PackageItem.fromJson(i))
          .toList() ?? [],
    );
  }
}

class PackageItem {
  final int id;
  final int quantity;
  final String serviceName;
  final double serviceRating; 
  final int serviceReviewsCount;

  PackageItem({
    required this.id, 
    required this.quantity, 
    required this.serviceName,
    required this.serviceRating,
    required this.serviceReviewsCount,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    final serviceJson = json['service'] ?? {};
    return PackageItem(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      serviceName: serviceJson['name'] ?? 'Unknown Service',
      serviceRating: double.tryParse(serviceJson['average_rating']?.toString() ?? '0') ?? 0.0,
      serviceReviewsCount: serviceJson['reviews_count'] ?? 0,
    );
  }
}