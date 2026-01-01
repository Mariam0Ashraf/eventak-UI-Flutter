
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/reusable_wedgits.dart';
import 'package:eventak/service-provider-UI/features/show_package/view/show_package_page.dart';
import 'package:eventak/service-provider-UI/features/show_package/view/my_packages_list_view.dart';

class PackageCard extends StatelessWidget {
  final Map<String, dynamic> package;
  final VoidCallback onRefreshNeeded;
  

  const PackageCard({
    super.key,
    required this.package,
    required this.onRefreshNeeded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final bool? result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowPackagePage(packageId: package['id']),
          ),
        );
        
        if (result == true) {
          onRefreshNeeded();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            Text(
              package['name'] ?? 'Package',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

class PackagesSection extends StatelessWidget {
  final List<Map<String, dynamic>> packages;
  final VoidCallback onRefresh; 
  final VoidCallback onPressed; 

  const PackagesSection({
    super.key,
    required this.packages,
    required this.onRefresh,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPackages = packages.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // The Header title
            Text(
              'My Packages',
              style: TextStyle(
                color: AppColor.blueFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onPressed,
                  icon: Icon(Icons.add, size: 18 , color: AppColor.blueFont),
                  label: Text(
                    "Create",
                    style: TextStyle(
                      color: AppColor.blueFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 2. See All Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPackagesListPage()),
                    );
                  },
                 child: Text(
                    "See All",
                    style: TextStyle(
                      color: AppColor.blueFont,
                      fontWeight: FontWeight.bold, 
                    ),
                 ),
                ),
              ],
            ),
          ],
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
                        onRefreshNeeded: onRefresh,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}