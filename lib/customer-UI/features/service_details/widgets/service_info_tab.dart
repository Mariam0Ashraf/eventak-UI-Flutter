import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:flutter/material.dart';

class ServiceInfoTab extends StatelessWidget {
  final MyService service;
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
            return Icon(
              index < rating.round() ? Icons.star : Icons.star_border,
              size: 16,
              color: Colors.amber,
            );
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
    //final providerImage = service.providerImage ?? 'assets/App_photos/provider.jpg';
    //final providerRating = service.providerRating ?? 0.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Service Category', service.categoryName!),
          _infoRow('Location', service.location??'-'),
          _infoRow('Base Price', 
                    '${service.basePrice?.toStringAsFixed(2) ?? '-'} ${service.priceUnit ?? ''}',
                  ),
          _buildRatingRow('Service Rating:', 4.7), //not in the endpoints yet 
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
          const SizedBox(height: 20),

          const Text(
            'Service Provider',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage('assets/App_photos/provider.jpg'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    providerName,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const Text(
                    'Photographer',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  _buildRatingRow('Provider Rating:', 4.9),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
