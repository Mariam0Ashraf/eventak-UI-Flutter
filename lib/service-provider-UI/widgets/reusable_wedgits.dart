// lib/service-provider-UI/shared/widgets/reusable_widgets.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

// ------------------- Reusable Section Header -------------------
class SectionHeader extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  const SectionHeader({
    super.key,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add, size: 18),
          label: Text(buttonText),
          style: TextButton.styleFrom(
            foregroundColor: AppColor.blueFont,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ------------------- Reusable Empty State -------------------
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({ 
    super.key,
    required this.message, 
    required this.icon,    
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}