import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/budget_service.dart';
import '../data/budget_model.dart';

class RecordPaymentDialog extends StatefulWidget {
  final int eventId;
  final BudgetItem item;
  final VoidCallback onSuccess;

  const RecordPaymentDialog({
    super.key,
    required this.eventId,
    required this.item,
    required this.onSuccess,
  });

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _service = BudgetService();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isSubmitting = true);
    final success = await _service.recordPayment(widget.eventId, widget.item.id, amount);

    if (success && mounted) {
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record Payment: ${widget.item.itemName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Remaining: \EGP ${widget.item.remainingAmount}', 
               style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Payment Amount",
              prefixText: "\EGP ",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, foregroundColor: Colors.white),
          child: _isSubmitting 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Record'),
        ),
      ],
    );
  }
}