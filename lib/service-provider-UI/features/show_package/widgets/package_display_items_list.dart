import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/package_details_model.dart';

class PackageDisplayItemsList extends StatelessWidget {
  final List<PackageItem> items;

  const PackageDisplayItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Included Services', 
          style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: item.thumbnail != null ? NetworkImage(item.thumbnail!) : null,
                    child: item.thumbnail == null ? const Icon(Icons.image) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.categoryName != null) _tag(item.categoryName!, Colors.blue),
                            if (item.areaName != null) ...[
                              const SizedBox(width: 6),
                              _tag(item.areaName!, Colors.orange),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('x${item.quantity}', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}