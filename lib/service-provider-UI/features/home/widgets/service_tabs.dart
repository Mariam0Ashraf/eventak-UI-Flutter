// lib/service-provider-UI/features/home/widgets/service_tabs.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class ServiceTabs extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final int? selectedServiceId;
  final ValueChanged<int?> onServiceSelected;

  const ServiceTabs({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.onServiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (services.length <= 1) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTab(title: 'All Services', serviceId: null),
          ...services.map(
            (service) =>
                _buildTab(title: service['name'], serviceId: service['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({required String title, required int? serviceId}) {
    final bool isSelected = selectedServiceId == serviceId;

    return GestureDetector(
      onTap: () => onServiceSelected(serviceId),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColor.blueFont,
          ),
        ),
      ),
    );
  }
}