// lib/service-provider-UI/shared/widgets/offers_section.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/widgets/reusable_wedgits.dart'; // Import utilities

class OfferCard extends StatelessWidget {
  final Map<String, String> offer;

  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, 
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.blueFont.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.discount, color: AppColor.blueFont, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  offer['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            offer['details']!,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(), 
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: AppColor.blueFont,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => debugPrint('Edit Offer: ${offer['title']}'),
                tooltip: 'Edit Offer',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => debugPrint('Delete Offer: ${offer['title']}'),
                tooltip: 'Delete Offer',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OffersSection extends StatelessWidget {
  final List<Map<String, String>> offers;

  const OffersSection({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    final bool hasOffers = offers.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'My Offers',
          buttonText: 'Add Offer',
          onPressed: () => debugPrint('Navigate to Add Offer'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100, 
          child: !hasOffers
              ? const EmptyState(
                    message: 'You did not add offers.', 
                    icon: Icons.widgets_outlined,
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: OfferCard(offer: offer),
                    );
                  },
                ),
        ),
      ],
    );
  }
}