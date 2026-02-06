import 'dart:convert';

class ServiceData {
  final int id;
  final String? categoryName;
  final String name;
  final String? description;
  final double basePrice;
  final String? priceUnit;
  final String? location;
  final String? area;
  final int? areaId;
  final String type;
  final int? capacity;
  final bool fixedCapacity;
  final String? address;
  final bool isActive;
  final String? providerName;
  final int? providerId;
  final String? providerAvatar;
  final String? image;
  final List<String> galleryImages;
  final int reviewsCount;
  final double averageRating;
  final List<AvailableArea>? availableAreas;
  final int minimumNoticeHours;
  final int minimumDurationHours;

  ServiceData({
    required this.id,
    this.categoryName,
    required this.name,
    this.description,
    required this.basePrice,
    this.priceUnit,
    this.location,
    this.area,
    this.areaId,
    required this.type,
    this.capacity,
    required this.fixedCapacity,
    this.address,
    this.isActive = true,
    this.providerName,
    this.providerId,
    this.providerAvatar,
    this.image,
    this.galleryImages = const [],
    required this.averageRating,
    required this.reviewsCount,
    this.availableAreas,
    required this.minimumNoticeHours,
    required this.minimumDurationHours,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => (v == null) ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
    double parseDouble(dynamic v) => (v == null) ? 0.0 : (v is double ? v : (v is int ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0));

    final provider = json['provider'] ?? {};
    final areaData = json['area'];
    final serviceType = json['service_type'];

    String? catName;
    final categories = json['categories'];
    if (categories is List && categories.isNotEmpty) {
      catName = categories.whereType<Map<String, dynamic>>().map((c) => c['name']?.toString() ?? '').where((name) => name.isNotEmpty).join(', ');
    }

    List<String> gallery = [];
    if (json['gallery'] is List) {
      gallery = (json['gallery'] as List).map((e) => e['url']?.toString() ?? '').toList();
    }

    return ServiceData(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      basePrice: parseDouble(json['base_price']),
      priceUnit: json['price_unit'],
      location: areaData != null ? areaData['name'] : null,
      area: areaData != null ? areaData['name'] : null,
      areaId: parseInt(json['area_id']),
      type: serviceType != null ? serviceType['name'] : (json['type'] ?? 'service'),
      capacity: json['capacity'],
      fixedCapacity: json['fixed_capacity'] == true || json['fixed_capacity'] == 1,
      address: json['address'],
      categoryName: catName,
      image: json['thumbnail_url'] ?? json['image'],
      galleryImages: gallery,
      reviewsCount: parseInt(json['reviews_count']),
      averageRating: parseDouble(json['average_rating']),
      providerName: provider['name'],
      providerId: parseInt(provider['id']),
      providerAvatar: provider['avatar'],
      isActive: true,
      minimumNoticeHours: parseInt(json['minimum_notice_hours']),
      minimumDurationHours: parseInt(json['minimum_duration_hours']),
    );
  }
}

class AvailableArea {
  final int id;
  final String name;
  final String type;
  AvailableArea({required this.id, required this.name, required this.type});
  factory AvailableArea.fromJson(Map<String, dynamic> json) => AvailableArea(id: json['id'] ?? 0, name: json['name'] ?? '', type: json['type'] ?? '');
}