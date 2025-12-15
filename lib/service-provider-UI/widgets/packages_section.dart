// lib/service-provider-UI/shared/widgets/packages_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/widgets/reusable_wedgits.dart'; // Import utilities

class PackageCard extends StatelessWidget {
  final Map<String, String> package;

  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.blueFont.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  package['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  package['details']!,
                  style:  TextStyle(color: AppColor.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(icon:  Icon(Icons.edit, size: 20, color: AppColor.grey), onPressed: () => debugPrint('Edit Package: ${package['title']}')),
        ],
      ),
    );
  }
}

class PackagesSection extends StatelessWidget {
  final List<Map<String, String>> packages;

  const PackagesSection({super.key, required this.packages});

  @override
  Widget build(BuildContext context) {
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
          height: 90, 
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
                      child: PackageCard(package: package),
                    );
                  },
                ),
        ),
      ],
    );
  }
}