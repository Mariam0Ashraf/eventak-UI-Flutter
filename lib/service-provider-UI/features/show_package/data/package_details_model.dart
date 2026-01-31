class PackageDetails {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String priceUnit;
  final bool fixedCapacity;
  final int capacity;
  final List<String> itemsSummary;
  final List<PackageItem> items; 
  final double averageRating;
  final int reviewsCount;
  final List<String> categories; 
  final List<int> categoryIds; 
  final PackageProvider? provider;

  PackageDetails({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.priceUnit,
    required this.fixedCapacity,
    required this.capacity,
    required this.itemsSummary,
    required this.items,
    required this.averageRating,
    required this.reviewsCount,
    required this.categories,
    required this.categoryIds, 
    this.provider,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    var categoryList = json['categories'] as List? ?? [];
    return PackageDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['base_price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      priceUnit: json['price_unit'] ?? 'package',
      fixedCapacity: json['fixed_capacity'] ?? true,
      capacity: json['capacity'] ?? 0,
      itemsSummary: List<String>.from(json['items_summary'] ?? []),
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      categories: categoryList.map((c) => c['name'].toString()).toList(),
      categoryIds: categoryList.map((c) => int.tryParse(c['id'].toString()) ?? 0).toList(),
      items: (json['items'] as List?)
          ?.map((i) => PackageItem.fromJson(i))
          .toList() ?? [],
      provider: json['provider'] != null ? PackageProvider.fromJson(json['provider']) : null,
    );
  }
}

class PackageProvider {
  final int id;
  final String name;
  final String? avatar;

  PackageProvider({required this.id, required this.name, this.avatar});

  factory PackageProvider.fromJson(Map<String, dynamic> json) {
    return PackageProvider(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class PackageItem {
  final int id;
  final int quantity;
  final String serviceName;
  final double serviceRating;
  final int serviceReviewsCount;
  final String? thumbnail; 
  final String? areaName; 
  final String? categoryName; 

  PackageItem({
    required this.id,
    required this.quantity,
    required this.serviceName,
    required this.serviceRating,
    required this.serviceReviewsCount,
    this.thumbnail,
    this.areaName,
    this.categoryName,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    final s = json['service'] ?? {};
    return PackageItem(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      serviceName: s['name'] ?? 'Unknown Service',
      serviceRating: double.tryParse(s['average_rating']?.toString() ?? '0') ?? 0.0,
      serviceReviewsCount: s['reviews_count'] ?? 0,
      thumbnail: s['thumbnail_url'],
      areaName: s['area']?['name'],
      categoryName: s['service_type']?['name'],
    );
  }
}