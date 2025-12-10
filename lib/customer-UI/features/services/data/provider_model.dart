class ServiceProvider {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String priceRange;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.priceRange,
  });

  // Dummy Data Generator
  static List<ServiceProvider> getDummyData(String category) {
    return [
      ServiceProvider(
        id: '1',
        name: 'Ahmed Ali Photography',
        imageUrl: 'https://i.pravatar.cc/150?img=11', 
        rating: 4.8,
        priceRange: '\$200 - \$500',
      ),
      ServiceProvider(
        id: '2',
        name: 'Sara Lens Studio',
        imageUrl: 'https://i.pravatar.cc/150?img=5',
        rating: 4.8,
        priceRange: '\$200 - \$500',
      ),
      ServiceProvider(
        id: '3',
        name: 'Daniel Photography',
        imageUrl: 'https://i.pravatar.cc/150?img=3',
        rating: 4.8,
        priceRange: '\$200 - \$500',
      ),
      ServiceProvider(
        id: '4',
        name: 'Eardy Photography',
        imageUrl: 'https://i.pravatar.cc/150?img=9',
        rating: 4.8,
        priceRange: '\$200 - \$500',
      ),
      ServiceProvider(
        id: '5',
        name: 'Dhaar Williams',
        imageUrl: 'https://i.pravatar.cc/150?img=60',
        rating: 4.8,
        priceRange: '\$200 - \$500',
      ),
    ];
  }
}