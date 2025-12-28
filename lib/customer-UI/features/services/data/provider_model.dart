class ServiceProvider {
  final String id;
  final String name;
  final String serviceName;
  final String description;
  final String imageUrl;
  final double rating;
  final String priceRange;
  final int categoryId;
  final String categoryName;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.description,
    required this.serviceName,
    required this.imageUrl,
    required this.rating,
    required this.priceRange,
    required this.categoryId,
    required this.categoryName,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    final providerObj = json['provider'] ?? {};
    final price = json['base_price'] ?? '0';

    final String generatedImage = '';

    return ServiceProvider(
      id: json['id'].toString(),
      name: providerObj['name'] ?? 'Unknown',
      serviceName: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: generatedImage,
      rating: 4.5,
      priceRange: '\$$price',
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? 'unknown',
    );
  }
}
