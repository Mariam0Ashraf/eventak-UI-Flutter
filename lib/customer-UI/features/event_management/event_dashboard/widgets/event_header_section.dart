import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/shared/prev_page_button.dart';

class EventHeaderSection extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventHeaderSection({
    super.key,
    required this.title,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PrevPageButton(),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColor.blueFont,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppColor.primary,
            onPressed: onEdit,
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
