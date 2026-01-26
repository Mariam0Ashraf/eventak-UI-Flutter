import 'package:eventak/customer-UI/features/services/service_details/data/service_model.dart';

class PackageData {
  final int id;
  final String name;
  final String description;
  final double price;
  final int itemsCount;
  final List<PackageItem> items;
  final int providerId;
  final String providerName;
  final String? providerAvatar;
  final double averageRating;
  final int reviewsCount;
  final List<String> categories;

  PackageData({
    required this.id, required this.name, required this.description,
    required this.price, required this.itemsCount, this.items = const [],
    required this.providerId, required this.providerName, this.providerAvatar,
    required this.averageRating, required this.reviewsCount,
    this.categories = const [],
  });

  factory PackageData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems.map((e) => PackageItem.fromJson(e)).toList();

    return PackageData(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      items: itemsList,
      itemsCount: itemsList.length,
      providerId: json['provider']?['id'] ?? 0,
      providerName: json['provider']?['name'] ?? 'Unknown',
      providerAvatar: json['provider']?['avatar'],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      categories: (json['categories'] as List?)
          ?.map((c) => c['name'].toString())
          .toList() ?? const [],
    );
  }
}

class PackageItem {
  final int quantity;
  final ServiceData service;

  PackageItem({required this.quantity, required this.service});

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      quantity: json['quantity'] ?? 1,
      service: ServiceData.fromJson(json['service']),
    );
  }
}