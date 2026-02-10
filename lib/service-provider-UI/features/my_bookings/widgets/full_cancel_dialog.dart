import 'dart:ui';

import 'package:eventak/service-provider-UI/features/my_bookings/data/provider_booking_service.dart';
import 'package:eventak/service-provider-UI/features/my_bookings/view/booking_details_view.dart';
import 'package:flutter/material.dart';
class FullCancelDialog extends StatefulWidget {
  final int bookingId;
  final Function(String) onConfirm;

  const FullCancelDialog({super.key, required this.bookingId, required this.onConfirm});

  @override
  State<FullCancelDialog> createState() => _FullCancelDialogState();
}
class _FullCancelDialogState extends State<FullCancelDialog> {
  final ProviderBookingService _service = ProviderBookingService();
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = true;
  Map<String, dynamic>? _quote;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  void _fetchQuote() async {
    try {
      final data = await _service.fetchRefundQuote(widget.bookingId);
      if (mounted) {
        setState(() {
          _quote = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Cancel Whole Booking", style: TextStyle(fontWeight: FontWeight.bold)),
      content: _isLoading
          ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : _errorMessage != null
              ? Text(_errorMessage!, style: const TextStyle(color: Colors.red))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoRow("Paid Amount", "EGP ${_quote?['original_amount'] ?? '0.00'}"),
                      // Updated Label here
                      _buildInfoRow("Refund Percentage", "${_quote?['refund_percentage'] ?? 0}%"),
                      const Divider(height: 24),
                      _buildInfoRow("Total Refund", "EGP ${_quote?['refund_amount'] ?? 0}", isBold: true, color: Colors.green),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Reason for cancellation (optional)",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Keep Booking")),
        if (!_isLoading && _errorMessage == null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              widget.onConfirm(_reasonController.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Confirm Cancellation", style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
            color: color, 
            fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }
}