import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/budget_model.dart';

class BudgetListTile extends StatelessWidget {
  final BudgetItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onPay; 

  const BudgetListTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit, 
    required this.onPay,
  });

  Color _getStatusColor() {
    switch (item.paymentStatus) {
      case 'paid': return Colors.green;
      case 'partial': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(child: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(item.paymentStatusLabel, style: TextStyle(color: _getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCostInfo("Estimated", "\EGP ${item.estimatedCost}"),
                _buildCostInfo("Actual", "\EGP ${item.actualCost}"),
                _buildCostInfo("Paid", "\EGP ${item.paidAmount}", color: Colors.green),
              ],
            ),
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ]
          ],
        ),
              trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.payments_outlined, color: Colors.green), 
            onPressed: onPay, 
            tooltip: 'Record Payment',
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete),
        ],
      ),
      ),
    );
  }

  Widget _buildCostInfo(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}