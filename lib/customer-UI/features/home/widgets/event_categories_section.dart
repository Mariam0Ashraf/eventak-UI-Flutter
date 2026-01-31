// lib/customer-UI/shared/widgets/home_categories_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/widgets/section_header.dart';

class EventCategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final bool isLoading;

  const EventCategoriesSection({
    super.key,
    required this.categories,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(
          title: 'Events Categories',
          onViewAll: () => debugPrint('view all categories'),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, idx) {
              final item = categories[idx];
              final String label = item['name'] ?? 'Unknown';
              final String? imageUrl = item['image_url'];

              return GestureDetector(
                onTap: () {
                  // Navigate to your services view and pass the category ID/Name
                  debugPrint("Navigating to category: ${item['id']}");
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AllServicesTabsView(
                        categories: _apiServiceTypes, 
                        initialIndex: idx, // Pass the index to open the correct tab
                      ),
                    ),
                  ); */
                },
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.category_outlined,
                                        size: 30,
                                      ),
                                )
                              : const Icon(Icons.category_outlined, size: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColor.blueFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
