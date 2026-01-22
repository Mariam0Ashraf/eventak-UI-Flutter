class GalleryMedia {
  final int id;
  final String url;

  GalleryMedia({required this.id, required this.url});
}

class MyService {
  final int id;
  final int? categoryId;
  final String? categoryName;
  final List<int> categoryIds;
  final String name;
  final String? description;
  final double? basePrice;
  final String? priceUnit;
  final String? location;
  final String type;
  final int? capacity;
  final String? address;
  final bool isActive;
  final bool fixedCapacity;
  final String? providerName;
  final int? providerId;
  final String? image;

  final int? areaId;
  final int? serviceTypeId;
  final String? areaName;
  final String? serviceTypeName;
  final int? inventoryCount;

  final int? minimumNoticeHours;
  final int? minimumDurationHours;
  final int? bufferTimeMinutes;
  final List<int> availableAreaIds;

  final List<String> galleryUrls;
  final List<GalleryMedia> gallery;
  final Map<String, dynamic>? pricingConfig;

  MyService({
    required this.id,
    this.categoryId,
    this.categoryName,
    this.categoryIds = const [],
    required this.name,
    this.description,
    this.basePrice,
    this.priceUnit,
    this.location,
    required this.type,
    this.capacity,
    this.address,
    this.isActive = true,
    this.fixedCapacity = true,
    this.providerName,
    this.providerId,
    this.image,
    this.areaId,
    this.serviceTypeId,
    this.areaName,
    this.serviceTypeName,
    this.inventoryCount,
    this.minimumNoticeHours,
    this.minimumDurationHours,
    this.bufferTimeMinutes,
    this.availableAreaIds = const [],
    this.galleryUrls = const [],
    this.gallery = const [],
    this.pricingConfig,
  });

  factory MyService.fromJson(Map<String, dynamic> json) {
    // ---------- Helpers ----------
    int? _toIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String && v.isNotEmpty) return int.tryParse(v);
      return null;
    }

    int _toInt(dynamic v) => _toIntNullable(v) ?? 0;

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String && v.isNotEmpty) return double.tryParse(v);
      return null;
    }

    final rawGallery = json['gallery'];
    List<String> galleryUrls = [];
    List<GalleryMedia> galleryMedia = [];

    if (rawGallery is List) {
      for (var e in rawGallery) {
        if (e is Map) {
          final url = e['url']?.toString() ?? '';
          galleryUrls.add(url);
          galleryMedia.add(
            GalleryMedia(
              id: _toInt(e['id']),
              url: url,
            ),
          );
        } else if (e is String) {
          galleryUrls.add(e);
        }
      }
    }

    List<int> categoryIds = [];
    String? categoryName;
    int? categoryId;

    final categories = json['categories'];
    if (categories is List) {
      for (var c in categories) {
        if (c is Map) {
          final id = _toIntNullable(c['id']);
          if (id != null) categoryIds.add(id);
        } else {
          final id = _toIntNullable(c);
          if (id != null) categoryIds.add(id);
        }
      }
      if (categories.isNotEmpty && categories.first is Map) {
        categoryName = categories.first['name']?.toString();
        categoryId = categoryIds.isNotEmpty ? categoryIds.first : null;
      }
    }

    List<int> availableAreaIds = [];
    final availableAreas = json['available_areas'];
    if (availableAreas is List) {
      for (var a in availableAreas) {
        if (a is Map) {
          final id = _toIntNullable(a['id']);
          if (id != null) availableAreaIds.add(id);
        } else {
          final id = _toIntNullable(a);
          if (id != null) availableAreaIds.add(id);
        }
      }
    }

    return MyService(
      id: _toInt(json['id']),
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIds: categoryIds,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      basePrice: _toDouble(json['base_price']),
      priceUnit: json['price_unit']?.toString(),
      location: json['location']?.toString() ??
          (json['area'] != null ? json['area']['name']?.toString() : null),
      type: json['type']?.toString() ?? 'event_service',
      capacity: _toIntNullable(json['capacity']),
      address: json['address']?.toString(),
      image: json['thumbnail_url']?.toString() ??
          json['image']?.toString() ??
          json['image_url']?.toString(),
      fixedCapacity: json['fixed_capacity'] == true ||
          json['fixed_capacity']?.toString() == '1',
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] is bool
              ? json['is_active']
              : json['is_active'].toString() == '1'),
      providerName: json['provider'] != null
          ? json['provider']['name']?.toString()
          : 'Unknown',
      providerId: _toIntNullable(json['provider']?['id']),
      areaId: _toIntNullable(json['area_id']),
      serviceTypeId: _toIntNullable(json['service_type_id']),
      areaName: json['area'] != null ? json['area']['name']?.toString() : null,
      serviceTypeName: json['service_type'] != null
          ? json['service_type']['name']?.toString()
          : null,
      inventoryCount: _toIntNullable(json['inventory_count']),
      minimumNoticeHours: _toIntNullable(json['minimum_notice_hours']),
      minimumDurationHours: _toIntNullable(json['minimum_duration_hours']),
      bufferTimeMinutes: _toIntNullable(json['buffer_time_minutes']),
      availableAreaIds: availableAreaIds,
      galleryUrls: galleryUrls,
      gallery: galleryMedia,
      pricingConfig: json['pricing_config'] is Map
          ? Map<String, dynamic>.from(json['pricing_config'])
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'price_unit': priceUnit,
      'area_id': areaId,
      'service_type_id': serviceTypeId,
      'inventory_count': inventoryCount,
      'capacity': capacity,
      'address': address,
      'location': location,
      'is_active': isActive ? 1 : 0,
      'fixed_capacity': fixedCapacity ? 1 : 0,
      'type': type,
      'thumbnail_url': image,
      'minimum_notice_hours': minimumNoticeHours,
      'minimum_duration_hours': minimumDurationHours,
      'buffer_time_minutes': bufferTimeMinutes,
    };

    for (int i = 0; i < categoryIds.length; i++) {
      data['category_ids[$i]'] = categoryIds[i];
    }

    for (int i = 0; i < availableAreaIds.length; i++) {
      data['available_area_ids[$i]'] = availableAreaIds[i];
    }

    if (!fixedCapacity && pricingConfig != null) {
      data['pricing_config[capacity_step]'] = pricingConfig!['capacity_step'];
      data['pricing_config[step_fee]'] = pricingConfig!['step_fee'];
      data['pricing_config[max_capacity]'] = pricingConfig!['max_capacity'];
      data['pricing_config[min_capacity]'] = pricingConfig!['min_capacity'];
    }

    return data;
  }
}