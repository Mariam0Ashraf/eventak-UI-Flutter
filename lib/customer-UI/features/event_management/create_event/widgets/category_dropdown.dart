import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/event_types_model.dart';
import 'custom_text_field.dart';

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
    
    return CustomTextField(
      label: 'Event Category',
      isRequired: true,
      customWidget: DropdownButtonFormField<EventType>(
        value: items.contains(selected) ? selected : null,
        hint: const Text('Select a category'),
        isExpanded: true,
        validator: (value) {
          if (value == null) return 'Please select a category';
          return null;
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100, 
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
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
