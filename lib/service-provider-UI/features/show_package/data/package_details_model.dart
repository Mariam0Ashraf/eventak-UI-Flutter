class PackageDetails {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String priceUnit;
  final bool fixedCapacity;
  final int capacity;
  final List<PackageItem> items;
  final List<String> categories;
  final List<int> categoryIds;
  final double averageRating;
  final int reviewsCount;
  final PackageProvider? provider;
  final PricingConfig? pricingConfig;
  final List<Map<String, dynamic>> availableAreas;

  final int? inventoryCount;
  final int? minimumNoticeHours;
  final int? minimumDurationHours;
  final int? bufferTimeMinutes;

  PackageDetails({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.priceUnit,
    required this.fixedCapacity,
    required this.capacity,
    required this.items,
    required this.categories,
    required this.categoryIds,
    required this.averageRating,
    required this.reviewsCount,
    this.provider,
    this.pricingConfig,
    required this.availableAreas,
    this.inventoryCount,
    this.minimumNoticeHours,
    this.minimumDurationHours,
    this.bufferTimeMinutes,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    var categoryList = json['categories'] as List? ?? [];
    return PackageDetails(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0,
      priceUnit: json['price_unit'] ?? 'package',
      fixedCapacity: json['fixed_capacity'] ?? false,
      capacity: json['capacity'] ?? 0,
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      inventoryCount: json['inventory_count'],
      minimumNoticeHours: json['minimum_notice_hours'],
      minimumDurationHours: json['minimum_duration_hours'],
      bufferTimeMinutes: json['buffer_time_minutes'],
      categories: categoryList.map((c) => c['name'].toString()).toList(),
      categoryIds: categoryList.map((c) => int.tryParse(c['id'].toString()) ?? 0).toList(),
      items: (json['items'] as List?)?.map((i) => PackageItem.fromJson(i)).toList() ?? [],
      provider: json['provider'] != null ? PackageProvider.fromJson(json['provider']) : null,
      pricingConfig: json['pricing_config'] != null ? PricingConfig.fromJson(json['pricing_config']) : null,
      availableAreas: List<Map<String, dynamic>>.from(json['available_areas'] ?? []),
    );
  }
}

class PricingConfig {
  final int? capacityStep; 
  final double? stepFee;   
  final int? maxCapacity;  
  final int? maxDuration;  
  final double overtimeRate; 

  PricingConfig({
    this.capacityStep,
    this.stepFee,
    this.maxCapacity,
    this.maxDuration,
    required this.overtimeRate,
  });

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      capacityStep: json['capacity_step'],
      stepFee: (json['step_fee'] as num?)?.toDouble(),
      maxCapacity: json['max_capacity'],
      maxDuration: json['max_duration'],
      overtimeRate: (json['overtime_rate'] as num?)?.toDouble() ?? 0.0,
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
class PackageUpdateRequest {
  final String name;
  final String description;
  final double basePrice;
  final int capacity;
  final bool fixedCapacity;
  final String inventoryCount;
  final String minimumNoticeHours;
  final String minimumDurationHours;
  final String bufferTimeMinutes;
  final List<int> categoryIds;
  final List<int> availableAreaIds;
  final Map<String, dynamic> pricingConfig;

  PackageUpdateRequest({
    required this.name,
    required this.description,
    required this.basePrice,
    required this.capacity,
    required this.fixedCapacity,
    required this.inventoryCount,
    required this.minimumNoticeHours,
    required this.minimumDurationHours,
    required this.bufferTimeMinutes,
    required this.categoryIds,
    required this.availableAreaIds,
    required this.pricingConfig,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "base_price": basePrice,
      "capacity": capacity,
      "fixed_capacity": fixedCapacity,
      "inventory_count": inventoryCount,
      "minimum_notice_hours": minimumNoticeHours,
      "minimum_duration_hours": minimumDurationHours,
      "buffer_time_minutes": bufferTimeMinutes,
      "available_area_ids": availableAreaIds,
      "category_ids": categoryIds,
      "pricing_config": pricingConfig,
    };
  }
}