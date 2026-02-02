import 'package:flutter/material.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class CategorySelector extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final List<int> selectedIds;
  final Function(int, bool) onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: categories.map((cat) {
        final isSelected = selectedIds.contains(cat['id']);
        return FilterChip(
          label: Text(cat['name'] ?? ''),
          selected: isSelected,
          onSelected: (selected) => onSelected(cat['id'], selected),
        );
      }).toList(),
    );
  }
}