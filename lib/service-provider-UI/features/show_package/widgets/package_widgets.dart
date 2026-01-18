import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/package_details_model.dart';

class PackageItemsList extends StatelessWidget {
  final List<PackageItem> items;
  const PackageItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Included Services', 
          style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circle Thumbnail
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: item.thumbnail != null 
                    ? NetworkImage(item.thumbnail!) 
                    : null,
                child: item.thumbnail == null 
                    ? const Icon(Icons.image, color: Colors.grey) 
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item.serviceName, 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Text('x${item.quantity}', 
                          style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Area and Category Tags
                    Row(
                      children: [
                        if (item.categoryName != null) 
                          _buildSmallTag(item.categoryName!, Colors.blue.shade50, Colors.blue),
                        if (item.areaName != null) ...[
                          const SizedBox(width: 6),
                          _buildSmallTag(item.areaName!, Colors.orange.shade50, Colors.orange),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${item.serviceRating} (${item.serviceReviewsCount} reviews)',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSmallTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}