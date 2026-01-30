class Booking {
  final int id;
  final double subtotal;
  final double discount;
  final double total;
  final int pointsRedeemed;
  final double pointsDiscount;
  final String status;

  Booking({
    required this.id,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.pointsRedeemed,
    required this.pointsDiscount,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount_amount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      pointsRedeemed: json['points_redeemed'],
      pointsDiscount: (json['points_discount'] as num).toDouble(),
      status: json['status'],
    );
  }
}
