class ServiceData {
  final int id;

  // CATEGORY
  final String? categoryName;

  // BASIC
  final String name;
  final String? description;
  final double basePrice;
  final String? priceUnit;

  // LOCATION
  final String? location;
  final String? area;

  // TYPE
  final String type;

  // VENUE
  final int? capacity;
  final String? address;

  // STATUS
  final bool isActive;

  // PROVIDER
  final String? providerName;
  final int? providerId;
  final String? providerAvatar;

  // MEDIA
  final String? image;
  final List<String> galleryImages;

  // REVIEWS
  final int reviewsCount;
  final double averageRating;

  ServiceData({
    required this.id,
    this.categoryName,
    required this.name,
    this.description,
    required this.basePrice,
    this.priceUnit,
    this.location,
    this.area,
    required this.type,
    this.capacity,
    this.address,
    this.isActive = true,
    this.providerName,
    this.providerId,
    this.providerAvatar,
    this.image,
    this.galleryImages = const [],
    required this.averageRating,
    required this.reviewsCount,
  });



  factory ServiceData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    // PROVIDER
    final provider = json['provider'] ?? {};

    // AREA
    final areaData = json['area'];

    // SERVICE TYPE
    final serviceType = json['service_type'];

    // CATEGORY
    String? categoryName;
    final categories = json['categories'];
    if (categories is List && categories.isNotEmpty) {
      
      categoryName = categories
          .whereType<Map<String, dynamic>>()
          .map((c) => c['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .join(', ');
    }

    //GALLERY
    List<String> gallery = [];
    if (json['gallery'] is List) {
      gallery = (json['gallery'] as List)
          .map((e) => e['url']?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    }

    

    return ServiceData(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      basePrice: parseDouble(json['base_price']),
      priceUnit: json['price_unit'],

      // LOCATION FROM AREA
      location: areaData != null ? areaData['name'] : null,
      area: areaData != null ? areaData['name'] : null,

      // TYPE
      type: serviceType != null
          ? serviceType['name']
          : json['type'] ?? 'service',

      // VENUE
      capacity: json['capacity'],
      address: json['address'],

      // CATEGORY
      categoryName: categoryName,

      // MEDIA
      image: json['thumbnail_url'] ?? json['image'],
      galleryImages: gallery,

      // REVIEWS
      reviewsCount: parseInt(json['reviews_count']),
      averageRating: parseDouble(json['average_rating']),

      // PROVIDER
      providerName: provider['name'],
      providerId: parseInt(provider['id']),
      providerAvatar: provider['avatar'],

      isActive: true,
    );
  }

}