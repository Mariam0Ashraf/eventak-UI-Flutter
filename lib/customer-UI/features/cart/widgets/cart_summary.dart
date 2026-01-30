import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;
  final String? appliedPromo;
  final int pointsRedeemed;
  final double pointsDiscount;
  final String buttonText;
  final VoidCallback? onPressed;
  final TextEditingController? pointsController;
  final VoidCallback? onApplyPoints;
  final int userLoyaltyPoints;
  final bool isCheckout;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.appliedPromo,
    required this.pointsRedeemed,
    required this.pointsDiscount,
    required this.buttonText,
    this.onPressed,
    this.pointsController,
    this.onApplyPoints,
    required this.userLoyaltyPoints,
    this.isCheckout = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate potential savings based on what's in the text box
    final int inputPoints = int.tryParse(pointsController?.text ?? '0') ?? 0;
    final promoDiscount = discount - pointsDiscount;
    final bool isError = inputPoints > userLoyaltyPoints;
    final int updatedLoyaltyPoints = isError ? userLoyaltyPoints : userLoyaltyPoints - inputPoints;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
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
            /// --- Compact Points Input Row ---
            if (pointsController != null)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCompactInput(
                          controller: pointsController,
                          hint: "Enter Points to Use",
                          icon: Icons.stars_rounded,
                          onApply: onApplyPoints,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child:Text(
                          isError 
                            ? "Insufficient points! (only $updatedLoyaltyPoints pts avilable)" 
                            : "Available: $updatedLoyaltyPoints pts (5 EGP discount for every 100 pts)",
                          style: TextStyle(
                            fontSize: 10,
                            color: isError ? Colors.red : AppColor.primary, 
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            _buildPriceRow('Subtotal', subtotal),

            if (promoDiscount > 0)
              _buildPriceRow(
                'Promo Discount',
                -promoDiscount,
                isDiscount: true,
              ),

            if (pointsDiscount > 0)
              _buildPriceRow(
                'Points Discount ($pointsRedeemed pts)',
                -pointsDiscount,
                isDiscount: true,
              ),

            if (isCheckout && (discount > 0 || pointsDiscount > 0)) ...[
              const Divider(height: 16),
              _buildPriceRow(
                'Total Savings',
                -(discount), 
                isDiscount: true,
              ),
            ],

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: AppColor.blueFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInput({
    required TextEditingController? controller,
    required String hint,
    required IconData icon,
    required VoidCallback? onApply,
    bool isError = false,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColor.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError ? Colors.red : Colors.transparent,
          width: 1.5,
        )
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, size: 18, color: isError ? Colors.red : AppColor.primary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          TextButton(
            onPressed: isError ? null: onApply,
            child: Text(
              "Use",
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppColor.grey, fontSize: 14)),
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
