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
  final String? serviceType;
  final String? serviceTypeIcon;

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
    this.serviceType,
    this.serviceTypeIcon
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
          
      serviceTypeIcon: serviceTypeData != null 
          ? serviceTypeData['icon'] 
          : null,
    );
  }
}
