class MyService {
  final int id;
  final int? categoryId;
  final String name;
  final String? description;
  final double? basePrice;
  final String? priceUnit;
  final String? location;
  final bool isActive;

  MyService({
    required this.id,
    this.categoryId,
    required this.name,
    this.description,
    this.basePrice,
    this.priceUnit,
    this.location,
    this.isActive = true,
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

    return MyService(
      id: parseInt(json['id']),
      categoryId: json['category_id'] == null
          ? null
          : parseInt(json['category_id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      basePrice: parseDouble(json['base_price']),
      priceUnit: json['price_unit']?.toString(),
      location: json['location']?.toString(),
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] is bool
                ? json['is_active'] as bool
                : json['is_active'].toString() == '1'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'price_unit': priceUnit,
      'location': location,
      'is_active': isActive,
    };
  }
}
