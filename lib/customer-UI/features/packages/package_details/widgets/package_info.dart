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
          Text(
                "Package Categories:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColor.blueFont,
                ),
              ),
          if (package.categories.isNotEmpty)
            Padding(
              
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Wrap(
                spacing: 8,
                children: package.categories.map((cat) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.beige.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(Icons.grid_view_rounded, size: 14, color:AppColor.beige),
                      const SizedBox(width: 4),
                      Text(
                        cat,
                        style:  TextStyle(
                          color: AppColor.blueFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            )else
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                "No categories provided",
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[500],
                ),
              ),
            ),

          const SizedBox(height: 16),
          // Package price
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1F8), 
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                 Icon(
                  Icons.payments_outlined, 
                  color: AppColor.primary, 
                  size: 20
                ),
                const SizedBox(width: 12),
                Text(
                  package.price.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),

                const SizedBox(width: 4),
                const Text(
                  "EGP",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          
        ],
      ),
    );
  }
}
