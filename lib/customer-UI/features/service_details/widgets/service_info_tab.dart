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
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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
              return const Icon(Icons.star_border, size: 16, color: Colors.amber);
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
              Text('Service Rating: ', style: const TextStyle(fontWeight: FontWeight.w600, )),
              if (service.reviewsCount == 0) ...[
                const Text(
                  'No reviews yet (0)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ] else ...[
                _buildRatingRow(
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

          _infoRow('Service Category', service.categoryName ?? '-'),
          _infoRow('Service Type', service.type),
          _infoRow('Location/Area', service.area ?? service.location ?? '-'),
          _infoRow(
            'Base Price',
            '${service.basePrice.toStringAsFixed(2)} EGP / ${_formatPriceUnit(service.priceUnit)}',
          ),
          // ================= Notice & Duration =================

          Row(
            children: [
              Expanded(
                child: _infoRow(
                  'Minimum Notice',
                  '${service.minimumNoticeHours} hours',
                ),
              ),
              Tooltip(
                message: 'You must book at least this many hours before the event',
                child: const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  'Minimum Duration',
                  '${service.minimumDurationHours} hours',
                ),
              ),
              Tooltip(
                message: 'This is the shortest time you can book this service for',
                child: const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          if (service.type.toLowerCase() == 'venue' || service.capacity != null) ...[
            const SizedBox(height: 4),
            _infoRow('Capacity', '${service.capacity ?? 0} Persons'),
            _infoRow('Address', service.address ?? '-'),
          ],

          // ================= Available Areas =================

          if (service.availableAreas != null &&
              service.availableAreas!.isNotEmpty) ...[
            const SizedBox(height: 12),

            const Text(
              'Available Areas',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: service.availableAreas!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final area = service.availableAreas![index];

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          area.name,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],

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
                backgroundImage:
                    providerImage != null ? NetworkImage(providerImage) : null,
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
