import 'package:flutter/material.dart';

class PackageItemForm extends StatefulWidget {
  final List<Map<String, dynamic>> services;
  final Function(Map<String, dynamic>) onAdd;

  const PackageItemForm({
    super.key,
    required this.services,
    required this.onAdd,
  });

  @override
  State<PackageItemForm> createState() => _PackageItemFormState();
}

class _PackageItemFormState extends State<PackageItemForm> {
  int? _serviceId;
  int _quantity = 1;
  double _priceAdjustment = 0;
  String _itemDescription = '';

  void _addItem() {
    if (_serviceId == null) return;

    final selectedService = widget.services.firstWhere(
      (s) => s['id'] == _serviceId,
    );

    widget.onAdd({
      "service_id": _serviceId,
      "item_description": _itemDescription,
      "service_name": selectedService['name'],
      "quantity": _quantity,
      "price_adjustment": _priceAdjustment,
    });

    setState(() {
      _serviceId = null;
      _itemDescription = '';
      _quantity = 1;
      _priceAdjustment = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    //logging
    debugPrint('🔵 PackageItemForm services: ${widget.services}');
    debugPrint('🔵 PackageItemForm services count: ${widget.services.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Package Items',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        DropdownButtonFormField<int>(
          initialValue: _serviceId,
          decoration: const InputDecoration(labelText: 'Service'),
          items: widget.services.map((s) {
            return DropdownMenuItem<int>(
              value: s['id'],
              child: Text(s['name']),
            );
          }).toList(),
          onChanged: (v) => setState(() => _serviceId = v),
        ),

        TextField(
          decoration: const InputDecoration(
            labelText: 'Item Description',
            //hintText: 'e.g. full photo session',
          ),
          onChanged: (v) => _itemDescription = v,
        ),

        TextField(
          decoration: const InputDecoration(labelText: 'Quantity'),
          keyboardType: TextInputType.number,
          onChanged: (v) => _quantity = int.tryParse(v) ?? 1,
        ),

        TextField(
          decoration: const InputDecoration(
            labelText: 'Price Adjustment (EGP)',
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) => _priceAdjustment = double.tryParse(v) ?? 0,
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _addItem,
            child: const Text('Add Item'),
          ),
        ),
      ],
    );
  }
}
