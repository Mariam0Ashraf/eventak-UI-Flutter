import 'package:eventak/customer-UI/features/service_details/data/service_model.dart';
import 'package:flutter/material.dart';

class ServiceInfoTab extends StatelessWidget {
  final ServiceData service;
  const ServiceInfoTab({super.key, required this.service});

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.black54)),
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

  @override
  Widget build(BuildContext context) {
    final providerName = service.providerName ?? 'Unknown';
    //final providerRole = service.providerRole ?? '-';
    final providerImage = service.image ?? 'assets/App_photos/provider.jpg';
    //final providerRating = service.providerRating ?? 0.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Service Category', service.categoryName ?? '-'),
          _infoRow('Location', service.location ?? '-'),
          _infoRow(
            'Base Price',
            '${service.basePrice?.toStringAsFixed(2) ?? '-'} ${service.priceUnit ?? ''}',
          ),

          const SizedBox(height: 12),

          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            service.description ?? 'No description available',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          if (service.averageRating != null)
            Row(
              children: [
                if ((service.reviewsCount ?? 0) == 0) ...[
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
                    service.averageRating ?? 0.0,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(${service.reviewsCount} reviews)',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),

          const SizedBox(height: 20),
          const Text(
            'Service Provider',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: service.image != null
                      ? NetworkImage(service.image!)
                      : null,
                  child: service.image == null
                      ? const Icon(
                          Icons.person,
                          size: 28,
                          color: Colors.white70,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    providerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    'Photographer',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  _buildRatingRow(
                    'Service Rating:',
                    service.averageRating ?? 0.0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
