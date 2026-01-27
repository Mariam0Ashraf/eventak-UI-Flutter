import 'package:eventak/customer-UI/features/event_management/create_event/data/event_types_model.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class EventFilterBar extends StatelessWidget {
  final List<EventType> types;
  final EventType? selected;
  final Function(EventType?) onSelect;

  const EventFilterBar({
    super.key,
    required this.types,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: types.length + 1, // +1 for "All" tab
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          EventType? type;
          String label;

          if (index == 0) {
            type = null; // "All" tab
            label = "All";
          } else {
            type = types[index - 1];
            label = type.name;
          }

          final isSelected = selected == type;

          return GestureDetector(
            onTap: () => onSelect(type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
