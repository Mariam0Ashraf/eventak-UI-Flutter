import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class BudgetSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const BudgetSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final bool isOver = summary['is_over_budget'] ?? false;
    
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat("Estimated", "\EGP ${summary['total_estimated_cost']}"),
              _buildStat("Actual", "\EGP ${summary['total_actual_cost']}"),
              _buildStat("Paid", "\EGP ${summary['total_paid']}", color: Colors.green),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                "Remaining", 
                "\EGP ${summary['total_remaining']}", 
                color: Colors.orange.shade700
              ),
              _buildStat(
                "Variance", 
                "${summary['variance'] > 0 ? '+' : ''}\EGP ${summary['variance']}",
                color: isOver ? Colors.red : Colors.blue,
                subtitle: "${summary['variance_percentage']}%",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color, String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value, 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)
        ),
        if (subtitle != null)
          Text(subtitle, style: TextStyle(fontSize: 10, color: color?.withOpacity(0.7))),
      ],
    );
  }
}