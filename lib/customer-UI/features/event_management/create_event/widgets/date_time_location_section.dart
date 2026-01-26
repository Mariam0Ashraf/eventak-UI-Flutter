import 'package:eventak/customer-UI/features/event_management/create_event/widgets/labeld_text_field.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

final Color lightFillColor = Colors.grey.shade100;

class DateTimeLocationWidget extends StatelessWidget {
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController locationController;
  final TextEditingController addressController;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const DateTimeLocationWidget({
    super.key,
    required this.eventDate,
    required this.eventTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.dateController,
    required this.timeController,
    required this.locationController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Date',
          controller: dateController,
          readOnly: true,
          onTap: () => onDateChanged(DateTime.now()), // triggers pick
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please select event date';
            return null;
          },
          suffixIcon: Icons.calendar_today_outlined,
        ),
        CustomTextField(
          label: 'Time',
          controller: timeController,
          readOnly: true,
          onTap: () => onTimeChanged(TimeOfDay.now()), // triggers pick
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please select event time';
            return null;
          },
          suffixIcon: Icons.access_time_outlined,
        ),
        CustomTextField(
          label: 'Location',
          controller: locationController,
        ),
        CustomTextField(
          label: 'Address',
          controller: addressController,
        ),
      ],
    );
  }
}
