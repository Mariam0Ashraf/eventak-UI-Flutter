import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/booking/bookings/data/booking_item_model.dart';
import 'package:eventak/customer-UI/features/booking/bookings/widgets/footer_booking_item_card.dart';
import 'package:eventak/customer-UI/features/booking/bookings/widgets/header_booking_item_card.dart';
import 'package:eventak/customer-UI/features/booking/bookings/widgets/service_row_widget.dart';
import 'package:eventak/customer-UI/features/booking/checkout/data/booking_model.dart';
import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewDetails;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onViewDetails,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final items = booking.items;
    final bool isSingleItem = items.length == 1;

    return Container(
      margin: const EdgeInsets.all(16).copyWith(top: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(
            status: booking.statusLabel, //label
            id: booking.id,
            rawStatus: booking.status, //logic
            onCancel: onCancel,),
          const SizedBox(height: 12),

          if (isSingleItem) ...[
            // For single item
            ServiceRow(
              imageUrl: items.first.imageUrl,
              title: '${items.first.name} (${items.first.serviceType})',
              date: items.first.eventDate,
              time: '${items.first.startTime} - ${items.first.endTime}',
            ),
          ] else ...[
            const Text(
              'Booked Items',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16, color: AppColor.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.blueFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.serviceType} (${item.type == BookingItemType.package ? 'Package' : 'Service'})',
                              style: TextStyle(fontSize: 12, color: AppColor.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 16),
          Footer(
            total: booking.total,
            onViewDetails: onViewDetails,
            showCancel: booking.status == 'pending',
            onCancel: onCancel,
          ),
        ],
      ),
    );
  }
}



