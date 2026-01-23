import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class CategoryDropdown extends StatelessWidget {
  final List<EventType> types;
  final EventType? selected;
  final ValueChanged<EventType?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.types,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<EventType>(
      value: selected,
      hint: const Text('Select category'),
      items: types
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
