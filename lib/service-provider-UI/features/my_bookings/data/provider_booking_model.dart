class ProviderBooking {
  final int id;
  final double total;
  final String status;
  final String statusLabel;
  final String notes;
  final List<BookingItem> items;
  final String createdAt;

  ProviderBooking({
    required this.id,
    required this.total,
    required this.status,
    required this.statusLabel,
    required this.notes,
    required this.items,
    required this.createdAt,
  });

  factory ProviderBooking.fromJson(Map<String, dynamic> json) {
    return ProviderBooking(
      id: json['id'],
      total: double.parse(json['total'].toString()),
      status: json['status'],
      statusLabel: json['status_label'],
      notes: json['notes'] ?? "",
      items: (json['items'] as List).map((i) => BookingItem.fromJson(i)).toList(),
      createdAt: json['created_at'],
    );
  }
}

class BookingItem {
  final String name;
  final String thumbnailUrl;
  final double calculatedPrice;
  final String eventDate;

  BookingItem({
    required this.name, 
    required this.thumbnailUrl, 
    required this.calculatedPrice, 
    required this.eventDate
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      name: json['bookable']['name'],
      thumbnailUrl: json['bookable']['thumbnail_url'],
      calculatedPrice: double.parse(json['calculated_price'].toString()),
      eventDate: json['options']['event_date'],
    );
  }
}