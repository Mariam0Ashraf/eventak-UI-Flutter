import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
import '../data/package_model.dart';

class PackageInfoSection extends StatelessWidget {
  final PackageData package;

  const PackageInfoSection({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package description
          if (package.description.isNotEmpty)
            Text(
              package.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

          const SizedBox(height: 16),

          // Package rating
          Row(
            children: [
              Text(
                "Rating:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                package.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${package.reviewsCount} reviews)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Package price
          Row(
            children: [
              Text(
                "Package Price:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),

              Text(
                ' ${package.price} EGP',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          
        ],
      ),
    );
  }
}
