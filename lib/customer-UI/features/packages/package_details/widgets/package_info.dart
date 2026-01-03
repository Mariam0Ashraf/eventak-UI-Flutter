import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/package_model.dart';

class PackageInfoSection extends StatelessWidget {
  final PackageData package;

  const PackageInfoSection({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            package.description,
            style: TextStyle(color: Colors.grey[700]),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'EGP ${package.price}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Services Included',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
