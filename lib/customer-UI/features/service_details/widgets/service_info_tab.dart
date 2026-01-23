import 'package:eventak/customer-UI/features/service_details/data/service_model.dart';
import 'package:flutter/material.dart';

class ServiceInfoTab extends StatelessWidget {
  final ServiceData service;
  const ServiceInfoTab({super.key, required this.service});

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String title, double rating) {
    return Row(
      children: [
        Text('$title ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Icon(Icons.star, size: 16, color: Colors.amber);
            } else if (index < rating && rating - index >= 0.5) {
              return const Icon(Icons.star_half, size: 16, color: Colors.amber);
            } else {
              return const Icon(
                Icons.star_border,
                size: 16,
                color: Colors.amber,
              );
            }
          }),
        ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  String _formatPriceUnit(String? unit) {
    if (unit == null || unit.isEmpty) return '';
    return unit[0].toUpperCase() + unit.substring(1).replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final providerName = service.providerName ?? 'Unknown';
    final providerImage = service.providerAvatar; 
    
    debugPrint('Service Category: ${service.categoryName}');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Service Category', service.categoryName ?? '-'),
          _infoRow('Service Type', service.type),
          _infoRow('Location/Area', service.area ?? service.location ?? '-'),
          _infoRow(
            'Base Price',
            '${service.basePrice.toStringAsFixed(2)} EGP / ${_formatPriceUnit(service.priceUnit)}',
          ),
          
          if (service.type.toLowerCase() == 'venue' || service.capacity != null) ...[
            const SizedBox(height: 4),
            _infoRow('Capacity', '${service.capacity ?? 0} Persons'),
            _infoRow('Address', service.address ?? '-'),
          ],

          const Divider(height: 32),

          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            service.description ?? 'No description available',
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
          
          const SizedBox(height: 12),
          
          if (service.averageRating != null)
            Row(
              children: [
                if ((service.reviewsCount) == 0) ...[
                  const Text(
                    'Service Rating: No reviews yet (0)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ] else ...[
                  _buildRatingRow(
                    'Service Rating:',
                    service.averageRating,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${service.reviewsCount} reviews)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),

          const Divider(height: 40),
          
          const Text(
            'Service Provider',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: providerImage != null
                    ? NetworkImage(providerImage)
                    : null,
                child: providerImage == null
                    ? const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white70,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Verified Provider',
                    style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}