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

    return CancellationPolicy(
      minimumNoticeHours: json['minimum_notice_hours'],
      refundSchedule: rules,
      customNote: json['custom_conditions'] != null ? json['custom_conditions']['note'] : null,
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
  int daysBefore;
  int refundPercentage;

  RefundRule({required this.daysBefore, required this.refundPercentage});

  factory RefundRule.fromJson(Map<String, dynamic> json) {
    return RefundRule(
      daysBefore: json['days_before'] ?? 0,
      refundPercentage: json['refund_percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "days_before": daysBefore,
    "refund_percentage": refundPercentage,
  };
}