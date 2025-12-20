// lib/service-provider-UI/shared/widgets/portfolio_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/reusable_wedgits.dart'; // Import utilities


class PortfolioItem extends StatelessWidget {
  final Map<String, String> item;

  const PortfolioItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              item['image']!,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              item['desc']!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class PortfolioSection extends StatelessWidget {
  final List<Map<String, String>> portfolio;

  const PortfolioSection({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'My Portfolio',
          buttonText: 'Add Item',
          onPressed: () => debugPrint('Navigate to Add Portfolio Item'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: portfolio.length,
            itemBuilder: (context, index) {
              final item = portfolio[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: PortfolioItem(item: item),
              );
            },
          ),
        ),
      ],
    );
  }
}