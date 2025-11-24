import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class UserField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final Color fieldColor;
  final Color iconBackgroundColor;

  const UserField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    required this.fieldColor,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final darkFont = AppColor.blueFont;

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 8),
      height: 65,
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: darkFont.withOpacity(0.6),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: darkFont,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
