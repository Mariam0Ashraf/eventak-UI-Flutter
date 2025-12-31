import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/package_details_model.dart';

class PackageItemsList extends StatelessWidget {
  final List<PackageItem> items;
  const PackageItemsList({super.key, required this.items});

  List<Widget> _buildStars(double rating) {
    return List.generate(5, (i) {
      if (rating >= i + 1) {
        return const Icon(Icons.star, size: 14, color: Colors.amber);
      } else if (rating >= i + 0.5) {
        return const Icon(Icons.star_half, size: 14, color: Colors.amber);
      } else {
        return const Icon(Icons.star_border, size: 14, color: Colors.amber);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Included Services', 
          style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
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
                  Text('Qty: ${item.quantity}', 
                    style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ..._buildStars(item.serviceRating),
                  const SizedBox(width: 6),
                  Text(
                    '${item.serviceRating} (${item.serviceReviewsCount} reviews)',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }
}