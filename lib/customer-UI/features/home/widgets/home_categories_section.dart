// lib/customer-UI/shared/widgets/home_categories_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/widgets/section_header.dart';

class HomeCategoriesSection extends StatelessWidget {
  final List<Map<String, String>> categories;

  const HomeCategoriesSection({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: 'Events Categories',
          onViewAll: () => debugPrint('view all categories'),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, idx) {
              final item = categories[idx];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Image.network(
                        item['img']!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item['label']!, style: TextStyle(color: AppColor.blueFont)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}