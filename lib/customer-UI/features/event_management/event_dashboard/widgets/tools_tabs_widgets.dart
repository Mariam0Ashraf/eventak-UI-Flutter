import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class EventToolsTabs extends StatelessWidget {
  final int activeTabIndex;
  final Function(int) onTabSelected;

  const EventToolsTabs({
    super.key,
    required this.activeTabIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabItem(0, "Timeline"),
          _tabItem(1, "Todos"),
          _tabItem(2, "Budget"),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label) {
    bool isSelected = activeTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColor.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
  
}