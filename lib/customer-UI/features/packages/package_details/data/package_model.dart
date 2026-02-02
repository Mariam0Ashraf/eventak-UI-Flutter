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
  final List<int> categoryIds;
  
  final bool fixedCapacity;
  final int capacity;
  final PricingConfig? pricingConfig;
  final List<Map<String, dynamic>> availableAreas;

  PackageData({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.itemsCount,
    this.items = const [],
    required this.providerId,
    required this.providerName,
    this.providerAvatar,
    required this.averageRating,
    required this.reviewsCount,
    required this.categories,
    required this.categoryIds,
    required this.fixedCapacity,
    required this.capacity,
    this.pricingConfig,
    this.availableAreas = const [],
  });

  factory PackageData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final itemsList = rawItems.map((e) => PackageItem.fromJson(e)).toList();
    final categoryList = json['categories'] as List? ?? [];
    final areasList = (json['available_areas'] as List? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return PackageData(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['base_price'] as num).toDouble(),
      items: itemsList,
      itemsCount: itemsList.length,
      providerId: json['provider']?['id'] ?? 0,
      providerName: json['provider']?['name'] ?? 'Unknown',
      providerAvatar: json['provider']?['avatar'],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] ?? 0,
      categories: categoryList.map((c) => c['name'].toString()).toList(),
      categoryIds: categoryList.map((c) => c['id'] as int).toList(),
      fixedCapacity: json['fixed_capacity'] == true || json['fixed_capacity'].toString() == '1',
      capacity: json['capacity'] ?? 0,
      pricingConfig: json['pricing_config'] != null 
          ? PricingConfig.fromJson(json['pricing_config']) 
          : null,
      availableAreas: areasList,
    );
  }
}

class PricingConfig {
  final int? capacityStep;
  final double? stepFee;
  final int? maxCapacity;
  final int? includedHours;
  final int? maxDuration;
  final double? overtimeRate;

  PricingConfig({
    this.capacityStep,
    this.stepFee,
    this.maxCapacity,
    this.includedHours,
    this.maxDuration,
    this.overtimeRate,
  });

  factory PricingConfig.fromJson(Map<String, dynamic> json) {
    return PricingConfig(
      capacityStep: json['capacity_step'],
      stepFee: (json['step_fee'] as num?)?.toDouble(),
      maxCapacity: json['max_capacity'],
      includedHours: json['included_hours'],
      maxDuration: json['max_duration'],
      overtimeRate: (json['overtime_rate'] as num?)?.toDouble(),
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