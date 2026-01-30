class ServiceProvider {
  final int id;
  final String name;
  final String? description;
  final double? basePrice;
  final String? location;
  final String? providerName;
  final String? imageUrl;
  final List<String> categories;
  final double? averageRating;
  final String serviceType;
  final String? serviceTypeIcon;
  final int serviceTypeId;

  ServiceProvider({
    required this.id,
    required this.name,
    this.description,
    this.basePrice,
    this.location,
    this.providerName,
    this.imageUrl,
    required this.categories,
    this.averageRating,
    required this.serviceType,
    this.serviceTypeIcon,
    required this.serviceTypeId, // FIXED: added 'this.'
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] ?? {};
    final serviceTypeData = json['service_type'] as Map<String, dynamic>?;

    return ServiceProvider(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: (json['base_price'] as num?)?.toDouble(),
      location: json['location'],
      providerName: provider['name'],
      imageUrl: json['thumbnail_url'],
      categories: List<String>.from(json['categories'] ?? []),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      serviceType: json['service_type'] != null
          ? json['service_type']['name']
          : 'Service',
      serviceTypeId: json['service_type_id'] ?? 0,
      serviceTypeIcon: serviceTypeData != null ? serviceTypeData['icon'] : null,
    );
  }
}