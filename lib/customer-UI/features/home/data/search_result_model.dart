enum SearchResultType { service, package }

class SearchResult {
  final SearchResultType type;

  final int id;
  final String name;
  final String? imageUrl;

  final double price;
  final String? priceUnit;

  final double averageRating;
  final int reviewsCount;

  final String? location;
  final String? address;

  final String? providerName;
  final String? providerAvatar;

  final List<String> categories;

  /// backend service "type" (venue, event_service, ...)
  final String? backendType;

  const SearchResult({
    required this.type,
    required this.id,
    required this.name,
    this.imageUrl,
    required this.price,
    this.priceUnit,
    required this.averageRating,
    required this.reviewsCount,
    this.location,
    this.address,
    this.providerName,
    this.providerAvatar,
    this.categories = const [],
    this.backendType,
  });

  String get displayLocation {
    final a = (address ?? '').trim();
    if (a.isNotEmpty) return a;

    final l = (location ?? '').trim();
    if (l.isNotEmpty) return l;

    return '';
  }

  factory SearchResult.fromJson(Map<String, dynamic> json, SearchResultType t) {
    if (t == SearchResultType.service) {
      return SearchResult.fromServiceJson(json);
    }
    return SearchResult.fromPackageJson(json);
  }

  factory SearchResult.fromServiceJson(Map<String, dynamic> json) {
    return SearchResult(
      type: SearchResultType.service,
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      imageUrl:
          (json['thumbnail_url'] ??
                  json['image_url'] ??
                  json['image'] ??
                  json['thumbnail'])
              ?.toString(),
      price: _toDouble(json['base_price'] ?? json['price']),
      priceUnit: json['price_unit']?.toString(),
      averageRating: _toDouble(json['average_rating']),
      reviewsCount: _toInt(json['reviews_count']),
      location: json['location']?.toString(),
      address: json['address']?.toString(),
      providerName: (json['provider'] is Map)
          ? (json['provider']['name'])?.toString()
          : null,
      providerAvatar: (json['provider'] is Map)
          ? (json['provider']['avatar'])?.toString()
          : null,
      categories: _toStringList(json['categories']),
      backendType: json['type']?.toString(),
    );
  }

  factory SearchResult.fromPackageJson(Map<String, dynamic> json) {
    String? extractedLocation = json['location']?.toString();
    String? extractedAddress = json['address']?.toString();

    final items = json['items'];
    if ((extractedLocation == null || extractedLocation!.isEmpty) ||
        (extractedAddress == null || extractedAddress!.isEmpty)) {
      if (items is List && items.isNotEmpty) {
        final first = items.first;
        if (first is Map) {
          final svc = first['service'];
          if (svc is Map) {
            extractedLocation ??= svc['location']?.toString();
            extractedAddress ??= svc['address']?.toString();
          }
        }
      }
    }

    final services = json['services'];
    if ((extractedLocation == null || extractedLocation!.isEmpty) ||
        (extractedAddress == null || extractedAddress!.isEmpty)) {
      if (services is List && services.isNotEmpty) {
        final first = services.first;
        if (first is Map) {
          extractedLocation ??= first['location']?.toString();
          extractedAddress ??= first['address']?.toString();
        }
      }
    }

    return SearchResult(
      type: SearchResultType.package,
      id: _toInt(json['id']),
      name: (json['name'] ?? '').toString(),
      imageUrl:
          (json['thumbnail_url'] ??
                  json['image_url'] ??
                  json['image'] ??
                  json['thumbnail'])
              ?.toString(),
      price: _toDouble(json['price'] ?? json['base_price']),
      priceUnit: json['price_unit']?.toString(),
      averageRating: _toDouble(json['average_rating']),
      reviewsCount: _toInt(json['reviews_count']),
      location: extractedLocation,
      address: extractedAddress,
      providerName: (json['provider'] is Map)
          ? (json['provider']['name'])?.toString()
          : null,
      providerAvatar: (json['provider'] is Map)
          ? (json['provider']['avatar'])?.toString()
          : null,
      categories: _toStringList(json['categories']),
      backendType: json['type']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static List<String> _toStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
