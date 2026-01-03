import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
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
          // Package description
          Text(
            package.description,
            style: TextStyle(color: Colors.grey[700]),
          ),

          const SizedBox(height: 16),

          // Package rating
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                package.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '(${package.reviewsCount} reviews)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Simplified package price
          Text(
            'Package price:  ${package.price} EGP',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.blueFont,
            ),
          ),

          const SizedBox(height: 24),

          // Services title
          const Text(
            'Services Included',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
