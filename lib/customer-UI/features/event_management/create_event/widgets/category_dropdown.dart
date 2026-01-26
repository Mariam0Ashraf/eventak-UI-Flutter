import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/event_types_model.dart';
import 'labeld_text_field.dart';

class CategoryDropdown extends StatelessWidget {
  final EventType? selected;
  final List<EventType> items;
  final ValueChanged<EventType?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.selected,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ⏳ Loading state
    /*if (items.isEmpty) {
      return CustomTextField(
        label: 'Event Category',
        customWidget: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Loading categories...',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }*/

    return CustomTextField(
      label: 'Event Category',
      customWidget: DropdownButtonFormField<EventType>(
        value: items.contains(selected) ? selected : null,
        hint: const Text('Select a category'),
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: items.map((e) {
          return DropdownMenuItem<EventType>(
            value: e,
            child: Text(
              e.name,
              style: TextStyle(
                color: AppColor.blueFont,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColor.blueFont.withOpacity(0.6),
        ),
        dropdownColor: Colors.white,
      ),
    );
  }
}
