import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/event_list_model.dart';
import 'event_progress_bar.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/widgets/date_countdown.dart';


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
              "${_formatDate(event.eventDate)} • ${friendlyDate(event.eventDate)}",
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
              children: [
                _buildCount(Icons.check_circle, event.todosCount, Colors.orange.shade100, 'Todos'),
                const SizedBox(width: 6), 
                _buildCount(Icons.attach_money, event.budgetItemsCount, Colors.green.shade100, 'Budget'),
                const SizedBox(width: 6), // Fixed gap
                _buildCount(Icons.timeline, event.timelinesCount, AppColor.beige, 'Timeline'),
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
    return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColor.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              "$count $label",
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Adds ... if it's too tight
              style: TextStyle(
                color: AppColor.blueFont,
                fontSize: 10, // Reduced from 13 for mobile density
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

}
