import 'package:flutter/material.dart';
import '../data/package_model.dart';

class BookPackageSheet extends StatefulWidget {
  final PackageData package;

  const BookPackageSheet({super.key, required this.package});

  @override
  State<BookPackageSheet> createState() => _BookPackageSheetState();
}

class _BookPackageSheetState extends State<BookPackageSheet> {
  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book ${widget.package.name}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          ListTile(
            title: const Text('Select Date'),
            trailing: Text(
              _date == null ? 'Choose' : _date!.toLocal().toString().split(' ')[0],
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),

          ListTile(
            title: const Text('Select Time'),
            trailing: Text(_time?.format(context) ?? 'Choose'),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) setState(() => _time = picked);
            },
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Center(child: Text('Add to Cart')),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
