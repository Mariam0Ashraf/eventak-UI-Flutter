enum BookingItemType { service, package }

class Booking {
  final int id;
  final double subtotal;      
  final double discount;      
  final double total;
  final int pointsRedeemed;   
  final double pointsDiscount; 
  final String status;
  final String statusLabel;
  final String? notes;        
  final List<BookingItem> items;
  final List<Transaction> transactions; 
  final String createdAt;      

  Booking({
    required this.id,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.pointsRedeemed,
    required this.pointsDiscount,
    required this.status,
    required this.statusLabel,
    this.notes,
    required this.items,
    required this.transactions,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      pointsRedeemed: json['points_redeemed'] ?? 0,
      pointsDiscount: double.tryParse(json['points_discount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'] ?? 'Pending',
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      items: (json['items'] as List? ?? [])
          .map((i) => BookingItem.fromJson(i))
          .toList(),
      transactions: (json['transactions'] as List? ?? [])
          .map((t) => Transaction.fromJson(t))
          .toList(),
    );
  }
}

class Transaction {
  final int id;
  final String type;
  final String status;
  final double? amount;
  final Map<String, dynamic>? meta;

  Transaction({
    required this.id,
    required this.type,
    required this.status,
    this.amount,
    this.meta,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      meta: json['meta'],
    );
  }
}

class BookingItem {
  final int id;
  final BookingItemType type;
  final String serviceType;
  final String name;
  final String description;
  final String? imageUrl;
  final double unitPrice;
  final int capacity;
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
    
    return BookingItem(
      id: json['id'] ?? 0,
      type: (json['bookable_type'] as String? ?? '').contains('service_package')
          ? BookingItemType.package
          : BookingItemType.service,
      serviceType: serviceTypeData['name']?.toString() ?? '',
      name: bookable['name'] ?? '',
      description: bookable['description'] ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      capacity: json['capacity'] ?? 1,
      eventDate: options['event_date'] ?? '',
      startTime: options['start_time'] ?? '',
      endTime: options['end_time'] ?? '',
      imageUrl: bookable['thumbnail_url'],
    );
  }
}