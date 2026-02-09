class CancellationPolicy {
  final int? minimumNoticeHours;
  final List<RefundRule> refundSchedule;
  final String? customNote;

  CancellationPolicy({
    this.minimumNoticeHours,
    required this.refundSchedule,
    this.customNote,
  });

  factory CancellationPolicy.fromJson(Map<String, dynamic> json) {
    var list = json['refund_schedule'] as List? ?? [];
    List<RefundRule> rules = list.map((i) => RefundRule.fromJson(i)).toList();

    String? extractedNote;
    if (json['custom_conditions'] != null && json['custom_conditions'] is Map) {
      extractedNote = json['custom_conditions']['note'];
    }

    return CancellationPolicy(
      minimumNoticeHours: json['minimum_notice_hours'] is String 
          ? int.tryParse(json['minimum_notice_hours']) 
          : json['minimum_notice_hours'],
      refundSchedule: rules,
      customNote: extractedNote,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "minimum_notice_hours": minimumNoticeHours,
      "refund_schedule": refundSchedule.map((e) => e.toJson()).toList(),
      "custom_conditions": {"note": customNote ?? ""}
    };
  }
}

class RefundRule {
  final int daysBefore;
  final int refundPercentage;

  RefundRule({required this.daysBefore, required this.refundPercentage});

  factory RefundRule.fromJson(Map<String, dynamic> json) {
    return RefundRule(
      daysBefore: json['days_before'] is String 
          ? int.parse(json['days_before']) 
          : (json['days_before'] ?? 0),
      refundPercentage: json['refund_percentage'] is String 
          ? int.parse(json['refund_percentage']) 
          : (json['refund_percentage'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
    "days_before": daysBefore,
    "refund_percentage": refundPercentage,
  };
}