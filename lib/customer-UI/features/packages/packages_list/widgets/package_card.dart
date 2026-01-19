import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/packages/package_details/data/package_model.dart';
import 'package:eventak/customer-UI/features/packages/package_details/view/package_details_view.dart';

class PackageCard extends StatelessWidget {
  final PackageData package;

  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package name
                Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Package description
                Text(
                  package.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                /*
                if (package.categories.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: -8,
                    children: package.categories.take(3).map((cat) {
                      return Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColor.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],*/

                const SizedBox(height: 8),

                // Rating + price row
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      package.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${package.price} EGP",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PackageDetailsView(packageId: package.id),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36),
            ),
            child: const Text(
              'View Details',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
