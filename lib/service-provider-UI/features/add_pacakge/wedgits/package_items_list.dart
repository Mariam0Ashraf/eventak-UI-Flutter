import 'package:flutter/material.dart';

class PackageItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(int) onRemove;

  const PackageItemsList({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Add items to your package',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Card(
          child: ListTile(
            title: Text('Service Name: ${item['service_name']}'),
            subtitle: Text(
              'Qty: ${item['quantity']} | Adjustment: ${item['price_adjustment']}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onRemove(index),
            ),
          ),
        );
      }).toList(),
    );
  }
}
