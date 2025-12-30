class ServiceProvider {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final String? basePrice;
  final String? location;
  final String? providerName;
  final String? imageUrl; 

  ServiceProvider({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.basePrice,
    this.location,
    this.providerName,
    this.imageUrl, 
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category_id'];
    int extractedCategoryId = 0;

    if (categoryData is Map<String, dynamic>) {
      extractedCategoryId = categoryData['id'] ?? 0;
    } else if (categoryData is int) {
      extractedCategoryId = categoryData;
    }

    final provider = json['provider'] ?? {};

    return ServiceProvider(
      id: json['id'] ?? 0,
      categoryId: extractedCategoryId,
      name: json['name'] ?? '',
      description: json['description'],
      basePrice: json['base_price']?.toString(),
      location: json['location'],
      providerName: provider['name'],
      imageUrl: json['image'] ?? json['image_url'], 
    );
  }
}