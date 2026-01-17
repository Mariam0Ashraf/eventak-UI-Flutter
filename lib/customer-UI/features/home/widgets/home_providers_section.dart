// lib/customer-UI/shared/widgets/home_providers_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/widgets/section_header.dart';
import 'package:eventak/customer-UI/features/services/view/providers_list_view.dart';

class HomeProvidersSection extends StatelessWidget {
  final List<Map<String, dynamic>> apiServiceCategories;
  final bool isLoading;
  final String? errorMessage;

  const HomeProvidersSection({
    super.key,
    required this.apiServiceCategories,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    }

    return Column(
      children: [
        SectionHeader(
          title: 'Service Providers',
          onViewAll: () => debugPrint('view all providers'),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: apiServiceCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, idx) {
              final item = apiServiceCategories[idx];
              final String title = item['name'] ?? 'Service';
              final String apiImageUrl = item['img'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProvidersListView(
                        categoryTitle: title,
                      ),
                    ),
                  );

                },
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.primary.withOpacity(0.06)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          apiImageUrl.isNotEmpty
                              ? apiImageUrl
                              : 'invalid_placeholder_url', // Triggers errorBuilder on empty URL
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback logic
                            return Image.asset(
                              'assets/App_photos/img.png', // The desired local asset
                              height: 90,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColor.blueFont,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}