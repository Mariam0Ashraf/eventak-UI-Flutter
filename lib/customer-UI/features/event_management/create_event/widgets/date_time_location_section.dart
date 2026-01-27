import 'package:eventak/customer-UI/features/event_management/create_event/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class DateTimeLocationWidget extends StatelessWidget {
  final DateTime? eventDate;
  final TimeOfDay? eventTime;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController areaController;
  final TextEditingController locationController;
  final TextEditingController addressController;
  final VoidCallback onDateChanged;
  final VoidCallback onTimeChanged; 
  final VoidCallback onAreaTap;

  const DateTimeLocationWidget({
    super.key,
    required this.eventDate,
    required this.eventTime,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.dateController,
    required this.timeController,
    required this.areaController,
    required this.locationController,
    required this.addressController,
    required this.onAreaTap
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Date',
          controller: dateController,
          readOnly: true,
          isRequired: true, 
          onTap: onDateChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select event date';
            }
            return null;
          },
          suffixIcon: Icons.calendar_today_outlined,
        ),
        CustomTextField(
          label: 'Time',
          controller: timeController,
          readOnly: true,
          isRequired: true,
          onTap: onTimeChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select event time';
            }
            return null;
          },
          suffixIcon: Icons.access_time_outlined,
        ),
        CustomTextField(
          label: 'Area', 
          hint: 'Select your event area',
          controller: areaController,
          readOnly: true, 
          isRequired: true, 
          onTap: onAreaTap,
          suffixIcon: Icons.location_on_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Area is required';
            return null;
          },
        ),
        CustomTextField(
          label: 'Location',
          hint: 'e.g. Grand Ballroom',
          controller: locationController,
          isRequired: true, 
        ),
        CustomTextField(
          label: 'Detailed Address',
          hint: 'e.g. 123 Event St, Cairo',
          controller: addressController,
          isRequired: false, 
        ),
      ],
    );
  }
}