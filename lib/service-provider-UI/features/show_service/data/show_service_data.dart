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
  final String? providerName;
  final int? providerId;
  final String? image; 

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
    this.providerName,
    this.providerId,
    this.image,
  });

  factory MyService.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final provider = json['provider'] ?? {};
    
    final categoryData = json['category_id'];
    int? extractedId;
    String? extractedName;

    if (categoryData is Map<String, dynamic>) {
      extractedId = parseInt(categoryData['id']);
      extractedName = categoryData['name']?.toString();
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
      location: json['location']?.toString(),
      type: json['type']?.toString() ?? 'event_service',
      capacity: json['capacity'] != null ? parseInt(json['capacity']) : null,
      address: json['address']?.toString(),
      image: json['thumbnail_url'] ?? json['image'] ?? json['image_url'], 
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] is bool
              ? json['is_active'] as bool
              : json['is_active'].toString() == '1' || json['is_active'].toString() == 'active'),
      providerName: provider['name']?.toString() ?? 'Unknown',
      providerId: parseInt(provider['id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'price_unit': priceUnit,
      'location': location,
      'type': type,
      'capacity': capacity,
      'address': address,
      'is_active': isActive,
      'thumbnail_url': image,
    };
  }
}