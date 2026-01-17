import 'package:eventak/customer-UI/features/service_details/data/service_model.dart';

class PackageData {
  final int id;
  final String name;
  final String description;
  final String price;
  final int itemsCount;
  final List<PackageItem>? items;
  final ServiceData? provider;
  final double averageRating;
  final int reviewsCount;
  final int categoryId;

  PackageData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.itemsCount,
    this.items,
    this.provider,
    required this.averageRating,
    required this.reviewsCount,
    required this.categoryId,
  });

  factory PackageData.fromJson(Map<String, dynamic> json) {
    return PackageData(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      // FIX: Convert int/num to String safely
      price: json['price']?.toString() ?? '0', 
      // FIX: Provide default 0 if items_count is missing from JSON
      itemsCount: json['items_count'] ?? 0, 
      // FIX: Added null check for items
      items: json['items'] != null
          ? (json['items'] as List).map((e) => PackageItem.fromJson(e)).toList()
          : [],
      provider: json['provider'] != null 
          ? ServiceData.fromJson(json['provider']) 
          : null,
      // FIX: Handle cases where average_rating might be missing
      averageRating: (json['average_rating'] as num? ?? 0.0).toDouble(),
      reviewsCount: json['reviews_count'] ?? 0,
      categoryId: json['category_id'] ?? 1,
    );
  }
}

class PackageItem {
  final int quantity;
  final ServiceData service;

  PackageItem({required this.quantity, required this.service});

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      quantity: json['quantity'],
      service: ServiceData.fromJson(json['service']),
    );
  }
}

