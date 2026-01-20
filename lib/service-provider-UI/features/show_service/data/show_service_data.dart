class MyService {
  final int id;
  final int? categoryId;
  final String? categoryName;
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
  final List<String> galleryUrls;
  final Map<String, dynamic>? pricingConfig;

  MyService({
    required this.id,
    this.categoryId,
    this.categoryName,
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
    this.galleryUrls = const [],
    this.pricingConfig,
  });

  factory MyService.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) => (v == null) ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
    double? parseDouble(dynamic v) => (v == null) ? null : (v is double ? v : (v is int ? v.toDouble() : double.tryParse(v.toString())));

    final provider = json['provider'] ?? {};
    final area = json['area'] as Map<String, dynamic>?;
    final serviceType = json['service_type'] as Map<String, dynamic>?;
    final pricing = json['pricing_config'] as Map<String, dynamic>?;
    final galleryList = json['gallery'] as List? ?? [];
    List<String> urls = galleryList.map((e) => e['url'].toString()).toList();

    int? extractedId;
    String? extractedName;
    final categoriesList = json['categories'];
    final categoryData = json['category_id'];

    if (categoriesList is List && categoriesList.isNotEmpty) {
      final first = categoriesList[0];
      if (first is Map<String, dynamic>) {
        extractedId = parseInt(first['id']);
        extractedName = first['name']?.toString();
      }
    } else if (categoryData is Map<String, dynamic>) {
      extractedId = parseInt(categoryData['id']);
      extractedName = categoryData['name']?.toString();
    } else if (categoryData is String) {
      extractedName = categoryData;
    } else {
      extractedId = parseInt(categoryData);
    }

    return MyService(
      id: parseInt(json['id']),
      categoryId: extractedId,
      categoryName: extractedName,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      basePrice: parseDouble(json['base_price']),
      priceUnit: json['price_unit']?.toString(),
      location: json['location']?.toString() ?? area?['name']?.toString(),
      type: json['type']?.toString() ?? 'event_service',
      capacity: json['capacity'] != null ? parseInt(json['capacity']) : null,
      address: json['address']?.toString(),
      image: json['thumbnail_url'] ?? json['image'] ?? json['image_url'],
      fixedCapacity: json['fixed_capacity'] == true || json['fixed_capacity'].toString() == '1',
      isActive: json['is_active'] == null ? true : (json['is_active'] is bool ? json['is_active'] : json['is_active'].toString() == '1'),
      providerName: provider['name']?.toString() ?? 'Unknown',
      providerId: parseInt(provider['id']),
      areaId: parseInt(json['area_id']),
      serviceTypeId: parseInt(json['service_type_id']),
      areaName: area?['name'],
      serviceTypeName: serviceType?['name'],
      inventoryCount: parseInt(json['inventory_count']),
      galleryUrls: urls,
      pricingConfig: pricing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'price_unit': priceUnit,
      'category_ids[0]': categoryId,
      'area_id': areaId,
      'service_type_id': serviceTypeId,
      'inventory_count': inventoryCount,
      'capacity': capacity,
      'address': address,
      'is_active': isActive ? 1 : 0,
      'fixed_capacity': fixedCapacity ? 1 : 0,
      'type': type,
      'thumbnail_url': image,
    };
  }
}