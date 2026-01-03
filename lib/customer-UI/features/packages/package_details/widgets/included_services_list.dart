import 'package:flutter/material.dart';
import '../data/package_model.dart';

class PackageServicesList extends StatelessWidget {
  final List<PackageItem> items;

  const PackageServicesList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Approx height for 2 items (adjust as needed)
    final double containerHeight = items.length > 2
        ? 2 * 88.0
        : items.length * 88.0;

    return SizedBox(
      height: containerHeight,
      child: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(vertical: 4),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, index) {
          final item = items[index];
          final service = item.service;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text(service.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (service.location != null) Text(service.location!),
                  if (service.capacity != null)
                    Text('Capacity: ${service.capacity}'),
                  Text('Type: ${service.type}'),
                ],
              ),
              trailing: Text(
                'x${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
