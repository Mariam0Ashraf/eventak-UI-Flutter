// lib/service-provider-UI/shared/widgets/statistics_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
// Note: We don't need reusable_widgets here, just the StatCard helper
// Note: Data should ideally be passed in, but using a dummy list for simplicity

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.beige.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColor.blueFont),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColor.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using Text directly since SectionHeader requires a button
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            StatCard(
              title: 'Upcoming Bookings', 
              value: '3', 
              icon: Icons.event, 
              onTap: () => debugPrint('Upcoming Tapped')
            ),
            StatCard(
              title: 'New Requests', 
              value: '2', 
              icon: Icons.inbox, 
              onTap: () => debugPrint('Requests Tapped')
            ),
            StatCard(
              title: 'Reviews', 
              value: '4.8', 
              icon: Icons.star, 
              onTap: () => debugPrint('Reviews Tapped')
            ),
          ],
        ),
      ],
    );
  }
}