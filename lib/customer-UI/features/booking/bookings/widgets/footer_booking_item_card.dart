import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final double total;
  final VoidCallback onViewDetails;
  final bool showCancel;
  final VoidCallback? onCancel;

  const Footer({
    required this.total,
    required this.onViewDetails,
    required this.showCancel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'EGP ${total.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: onViewDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.background,
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