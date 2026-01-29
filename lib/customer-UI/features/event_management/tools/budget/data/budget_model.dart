class BudgetItem {
  final int id;
  final int eventId;
  final String category;
  final String itemName;
  final double estimatedCost;
  final double actualCost;
  final double paidAmount;
  final double remainingAmount;
  final double variance;
  final String paymentStatus;
  final String paymentStatusLabel;
  final String? notes;

  BudgetItem({
    required this.id,
    required this.eventId,
    required this.category,
    required this.itemName,
    required this.estimatedCost,
    required this.actualCost,
    required this.paidAmount,
    required this.remainingAmount,
    required this.variance,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    this.notes,
  });

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] ?? 0,
      eventId: json['event_id'] is String ? int.parse(json['event_id']) : (json['event_id'] ?? 0),
      category: json['category'] ?? '',
      itemName: json['item_name'] ?? '',
      estimatedCost: (json['estimated_cost'] ?? 0).toDouble(),
      actualCost: (json['actual_cost'] ?? 0).toDouble(),
      paidAmount: (json['paid_amount'] ?? 0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0).toDouble(),
      variance: (json['variance'] ?? 0).toDouble(),
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paymentStatusLabel: json['payment_status_label'] ?? 'Unpaid',
      notes: json['notes'],
    );
  }
}