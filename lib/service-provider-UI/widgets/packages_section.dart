// lib/service-provider-UI/shared/widgets/packages_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/widgets/reusable_wedgits.dart';

class PackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final Function(int) onDelete;

  const PackageCard({
    super.key,
    required this.package,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.blueFont.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  package['name'] ?? 'Package',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColor.grey,
                    ),
                    onPressed: () =>
                        debugPrint('Edit Package: ${package['id']}'),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final bool? confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Package'),
                          content: const Text(
                            'Are you sure you want to delete this package? '
                            'This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        onDelete(package['id']);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${package['price']} EGP',
            style: TextStyle(
              color: AppColor.blueFont,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            package['description'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColor.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}


class PackagesSection extends StatelessWidget {
  final List<Map<String, dynamic>> packages;
  final Function(int) onDelete;

  const PackagesSection({
    super.key, 
    required this.packages, 
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    //debugPrint("PackagesSection: Received ${packages.length} items"); //
    final bool hasPackages = packages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'My Packages',
          buttonText: 'Create Package',
          onPressed: () => debugPrint('Navigate to Create Package'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110, 
          child: !hasPackages
              ? const EmptyState(
                    message: 'You did not create packages yet.', 
                    icon: Icons.widgets_outlined,
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: PackageCard(
                        package: package,
                        onDelete: onDelete,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}