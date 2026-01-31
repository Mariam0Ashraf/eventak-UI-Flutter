import 'package:eventak/customer-UI/features/booking/bookings/data/booking_item_model.dart';

class Booking {
  final int id;
  final double subtotal;
  final double discount;
  final double total;
  final int pointsRedeemed;
  final double pointsDiscount;
  final String status;
   final String statusLabel;
  final List<BookingItem> items;

  Booking({
    required this.id,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.pointsRedeemed,
    required this.pointsDiscount,
    required this.status,
    required this.items,
    required this.statusLabel,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      pointsRedeemed: json['points_redeemed'] ?? 0,
      pointsDiscount: (json['points_discount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'],
      items: (json['items'] as List? ?? [])
          .map((e) => BookingItem.fromJson(e))
          .toList(),
    );
  }
  }
