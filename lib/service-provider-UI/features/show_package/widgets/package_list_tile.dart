import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class PackageListTile extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onTap;

  const PackageListTile({super.key, required this.package, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> itemsSummary = package['items_summary'] ?? [];
    final List<dynamic> cats = package['categories'] ?? [];

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
                      style: TextStyle(color: AppColor.blueFont, fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                Text('${package['base_price'] ?? package['price']} EGP',
                    style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            if (cats.isNotEmpty)
              Text(
                cats.map((e) => e['name']).join(' • '),
                style: TextStyle(color: AppColor.primary.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: 8),
            Text(package['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.list_alt, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    itemsSummary.join(', '),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Capacity: ${package['capacity']} guests ${package['fixed_capacity'] == true ? '(Fixed)' : ''}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    ),
                  ],
                ),
                if (package['provider'] != null)
                   Row(
                    children: [
                      CircleAvatar(
                        radius: 8,
                        backgroundImage: NetworkImage(package['provider']['avatar'] ?? ''),
                      ),
                      const SizedBox(width: 4),
                      Text(package['provider']['name'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}