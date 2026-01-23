import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

class DateTimePickerSection extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  const DateTimePickerSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onPickDate,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = selectedDate == null
        ? 'Select Date'
        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    final timeText =
        selectedTime == null ? 'Select Time' : selectedTime!.format(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'When and Where',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColor.blueFont,
            ),
          ),
        ),

        _pickerTile(
          icon: Icons.calendar_month_outlined,
          text: dateText,
          onTap: onPickDate,
        ),

        _pickerTile(
          icon: Icons.access_time_outlined,
          text: timeText,
          onTap: onPickTime,
        ),
      ],
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColor.blueFont),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: AppColor.blueFont,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
