import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class PackageListTile extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onTap;

  const PackageListTile({super.key, required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(package['name'] ?? 'Package',
                      style: TextStyle(color: AppColor.blueFont, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Text('${package['price']} EGP',
                    style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 6),
            Text(package['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 8),
            Text('${package['items_count'] ?? 0} Services included',
                style: TextStyle(color: AppColor.secondaryBlue, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}