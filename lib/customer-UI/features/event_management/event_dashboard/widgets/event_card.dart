import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/event_list_model.dart';
import 'event_progress_bar.dart';

class EventCard extends StatelessWidget {
  final EventListItem event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTypeBadge(),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.name,
              style: TextStyle(
                color: AppColor.blueFont,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${_formatDate(event.eventDate)} • ${_friendlyDate(event.eventDate)}",
              style: TextStyle(color: AppColor.grey, fontSize: 13),
            ),

            const SizedBox(height: 12),
            EventProgressBar(
              progress: event.completionPercentage,
              backgroundColor: Colors.grey.shade200,
              progressColor: AppColor.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCount(Icons.check_circle, event.todosCount, Colors.orange.shade100, 'Todos'),
                _buildCount(Icons.attach_money, event.budgetItemsCount, Colors.green.shade100, 'Budget'),
                _buildCount(Icons.timeline, event.timelinesCount, AppColor.beige, 'Timeline Items'),
              ],
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColor.secondaryBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        event.eventType.name,
        style: TextStyle(color: AppColor.blueFont),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${_monthName(date.month)} ${date.day}, ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  String _friendlyDate(DateTime date) {
  final now = DateTime.now();
  final eventDate = DateTime(date.year, date.month, date.day); 
  final today = DateTime(now.year, now.month, now.day);

  final difference = eventDate.difference(today).inDays;

  if (difference == 0) return "Today";
  if (difference == 1) return "Tomorrow";
  if (difference > 1) return "$difference days left";
  if (difference < 0) return "${-difference} days ago";

  return _formatDate(date); // fallback
}

  Widget _buildStatusChip() {
    Color bgColor;
    switch (event.statusLabel.toLowerCase()) {
      case "planning":
        bgColor = Colors.orange.shade300.withOpacity(0.8);
        break;
      case "completed":
        bgColor = Colors.green.shade400.withOpacity(0.8);
        break;
      case "pending":
        bgColor = Colors.grey.shade400;
        break;
      default:
        bgColor = AppColor.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        event.statusLabel,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCount(IconData icon, int count, Color bgColor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColor.primary),
          const SizedBox(width: 4),
          Text(
            "$count $label",
            style: TextStyle(
              color: AppColor.blueFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

}
