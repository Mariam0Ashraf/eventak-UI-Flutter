import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final String? appliedPromo;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.appliedPromo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow('Subtotal', subtotal),
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                'Discount ${appliedPromo != null ? "($appliedPromo)" : ""}',
                -discount,
                isDiscount: true,
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: TextStyle(
                    color: AppColor.blueFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text(
                  'Checkout Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColor.grey, fontSize: 14),
        ),
        Text(
          '${value.toStringAsFixed(2)} EGP',
          style: TextStyle(
            color: isDiscount ? Colors.green : AppColor.blueFont,
            fontSize: 14,
            fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}