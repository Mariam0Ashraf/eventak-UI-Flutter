class ProviderBooking {
  final int id;
  final double total;
  final String status;
  final String statusLabel;
  final String notes;
  final List<BookingItem> items;
  final List<Map<String, dynamic>> transactions; 
  final String createdAt;

  ProviderBooking({
    required this.id,
    required this.total,
    required this.status,
    required this.statusLabel,
    required this.notes,
    required this.items,
    required this.transactions, 
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
      transactions: List<Map<String, dynamic>>.from(json['transactions'] ?? []), 
      createdAt: json['created_at'],
    );
  }
}

class BookingItem {
  final int id;
  final String name;
  final String? thumbnailUrl; 
  final double calculatedPrice;
  final String eventDate;
  final String bookableType; 

  BookingItem({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    required this.calculatedPrice,
    required this.eventDate,
    required this.bookableType,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final bookable = json['bookable'] ?? {};
    return BookingItem(
      id: json['id'] ?? 0, 
      name: bookable['name'] ?? "Unknown Item",
      thumbnailUrl: bookable['thumbnail_url'], 
      calculatedPrice: double.tryParse(json['calculated_price'].toString()) ?? 0.0,
      eventDate: json['options']?['event_date'] ?? "N/A",
      bookableType: json['bookable_type'] ?? "service",
    );
  }
}