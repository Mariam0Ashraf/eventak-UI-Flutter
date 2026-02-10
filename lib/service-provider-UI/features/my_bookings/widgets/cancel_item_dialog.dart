import 'package:flutter/material.dart';

class CancelItemDialog extends StatefulWidget {
  final Function(String) onConfirm;

  const CancelItemDialog({super.key, required this.onConfirm});

  @override
  State<CancelItemDialog> createState() => _CancelItemDialogState();
}

class _CancelItemDialogState extends State<CancelItemDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text("Cancel Item", style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
              "Are you sure you want to cancel this specific item? This action might be subject to the cancellation policy."),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Reason for cancellation (optional)...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              fillColor: Colors.grey[50],
              filled: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Keep Item", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () {
            widget.onConfirm(_reasonController.text.trim());
            Navigator.pop(context);
          },
          child: const Text("Confirm Cancellation"),
        ),
      ],
    );
  }
}