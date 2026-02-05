import 'package:eventak/customer-UI/features/event_management/tools/guests&rvsp/widgets/guest_constants.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/guest_model.dart';

class GuestListTile extends StatelessWidget {
  final GuestItem guest;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onSendInvite;

  const GuestListTile({
    super.key,
    required this.guest,
    required this.onDelete,
    required this.onEdit,
    required this.onSendInvite,
  });

  Color _getStatusColor(String status) {
    if (status == 'attending') return Colors.green;
    if (status == 'pending') return Colors.orange;
    if (status == 'not_attending') return Colors.redAccent;
    if (status == 'maybe') return Colors.blueAccent;
    
    return Colors.grey;
  }

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColor.primary.withOpacity(0.1),
          child: Text(
            guest.fullName[0].toUpperCase(),
            style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          guest.fullName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColor.blueFont,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${guest.email ?? guest.phone ?? 'No contact'} • ${guest.totalGuests} Guests",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(guest.rsvpStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                GuestConstants.rsvpOptions[guest.rsvpStatus]! ,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(guest.rsvpStatus),
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onSendInvite,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                guest.invitationSent ? "Invited" : "Invite",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: guest.invitationSent ? AppColor.grey : AppColor.primary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}