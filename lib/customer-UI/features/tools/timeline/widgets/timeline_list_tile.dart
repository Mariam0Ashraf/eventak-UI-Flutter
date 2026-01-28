import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/timeline_model.dart';

class TimelineListTile extends StatelessWidget {
  final TimelineItem timeline;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final int index;

  const TimelineListTile({
    super.key,
    required this.timeline,
    required this.onDelete,
    required this.onEdit,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.access_time_filled_rounded,
            color: AppColor.primary,
            size: 20,
          ),
        ),
        title: Text(
          timeline.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColor.blueFont,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${timeline.startTime} - ${timeline.endTime}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${timeline.duration} min)',
                  style: TextStyle(
                    fontSize: 12, 
                    color: AppColor.primary, 
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
            if (timeline.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                timeline.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
            ReorderableDragStartListener(
              index: index - 1,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}