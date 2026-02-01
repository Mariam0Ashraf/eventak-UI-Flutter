enum BookingItemType { service, package }

class BookingItem {
  final int id;
  final BookingItemType type;
  final String serviceType;

  final String name;
  final String description;
  final String? imageUrl;

  final double unitPrice;
  final int capacity;

  // Booking info
  final String eventDate;
  final String startTime;
  final String endTime;

  BookingItem({
    required this.id,
    required this.type,
    required this.serviceType,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.capacity,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    this.imageUrl,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final bookable = json['bookable'] ?? {};
    final options = json['options'] ?? {};
    final serviceTypeData = bookable['service_type'] as Map<String, dynamic>? ?? {};
    final String extractedServiceType = serviceTypeData['name']?.toString() ?? '';
    return BookingItem(
      id: json['id'],
      type: (json['bookable_type'] as String).contains('service_package')
          ? BookingItemType.package
          : BookingItemType.service,
      name: bookable['name'] ?? '',
      description: bookable['description'] ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      capacity: json['capacity'] ?? 1,
      eventDate: options['event_date'] ?? '',
      startTime: options['start_time'] ?? '',
      endTime: options['end_time'] ?? '',
      imageUrl: bookable['thumbnail_url'],
      serviceType: extractedServiceType,
    );
  }
}
