import 'package:flutter/material.dart';

class PortfolioTab extends StatelessWidget {
  const PortfolioTab({super.key});

  final List<String> portfolioImages = const [
    'assets/App_photos/wedding.jpg',
    'assets/App_photos/Birthday-Cake-1.webp',
    'assets/App_photos/Graduation.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: portfolioImages.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                portfolioImages[index],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Luxury Wedding Setup',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Elegant decoration and premium lighting for wedding venues.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
