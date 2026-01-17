class ServiceProvider {
  final int id;
  final String name;
  final String? description;
  final double? basePrice;
  final String? location;
  final String? providerName;
  final String? imageUrl;
  final List<String> categories;

  ServiceProvider({
    required this.id,
    required this.name,
    this.description,
    this.basePrice,
    this.location,
    this.providerName,
    this.imageUrl,
    required this.categories,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] ?? {};

    return ServiceProvider(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      basePrice: (json['base_price'] as num?)?.toDouble(),
      location: json['location'],
      providerName: provider['name'],
      imageUrl: json['thumbnail_url'],
      categories: List<String>.from(json['categories'] ?? []),
    );
  }
}
