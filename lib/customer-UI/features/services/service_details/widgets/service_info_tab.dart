import 'package:eventak/customer-UI/features/services/service_details/data/service_model.dart';
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
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow(String? location) {
    if (location == null || location.trim().isEmpty) {
      return _infoRow('Location/Area', '-');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location/Area: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              location,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(double rating) {
    return Row(
      children: [
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
    final providerAvatar = service.providerAvatar; 

    final reviewsCount = service.reviewsCount ?? 0;
    final avgRating = service.averageRating ?? 0.0;

    final basePrice = service.basePrice ?? 0.0;
    final priceUnit = _formatPriceUnit(service.priceUnit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Row(
            children: [
              const Text(
                'Service Rating: ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              if (reviewsCount == 0) ...[
                const Text(
                  'No reviews yet (0)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ] else ...[
                _buildRatingRow(avgRating),
                const SizedBox(width: 6),
                Text(
                  '($reviewsCount reviews)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),

          const Divider(height: 40),

          _infoRow('Service Category', service.categoryName ?? '-'),
          _infoRow('Service Type', service.type),
          _locationRow(service.location),

          _infoRow(
            'Base Price',
            '${basePrice.toStringAsFixed(2)} EGP${priceUnit.isNotEmpty ? ' / $priceUnit' : ''}',
          ),

          if (service.capacity != null)
            _infoRow('Capacity', '${service.capacity} Persons'),
          if (service.address != null && service.address!.trim().isNotEmpty)
            _infoRow('Address', service.address!),

          const Divider(height: 32),

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
                backgroundImage: providerAvatar != null && providerAvatar.isNotEmpty
                    ? NetworkImage(providerAvatar)
                    : null,
                child: providerAvatar == null || providerAvatar.isEmpty
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
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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