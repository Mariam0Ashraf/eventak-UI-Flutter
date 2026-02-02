import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final double total;
  final VoidCallback onViewDetails;
  final bool showCancel;
  final VoidCallback? onCancel;
  final VoidCallback? onPay; 

  const Footer({
    super.key,
    required this.total,
    required this.onViewDetails,
    required this.showCancel,
    this.onCancel,
    this.onPay, 
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TOTAL PRICE DISPLAY
        Text(
          'EGP ${total.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const Spacer(),
        
        if (onPay != null) ...[
          ElevatedButton(
            onPressed: onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, 
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Pay Now',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],

        ElevatedButton(
          onPressed: onViewDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.background,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('View'),
        ),
      ],
    );
  }
}