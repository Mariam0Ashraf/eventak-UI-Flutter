import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/booking/bookings/widgets/booking_status_chip.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String status;
  final int id;
  final String rawStatus; 
  final VoidCallback? onCancel;

  const Header({
    required this.status,
    required this.id,
    required this.rawStatus,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    bool canShowMenu = rawStatus.toLowerCase() != 'cancelled';

    return Row(
      children: [
        Text(
          'Booking #$id',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColor.blueFont,
          ),
        ),
        const Spacer(),
        BookingStatusChip(status: status),
        
        if (canShowMenu)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'cancel' && onCancel != null) {
                onCancel!();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: const [
                    Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Cancel Booking', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}