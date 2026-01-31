import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/utils/app_alerts.dart';
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
    final item = booking.items.isNotEmpty ? booking.items.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          _Header(status: booking.statusLabel, id: booking.id),
          const SizedBox(height: 12),

          if (item != null) ...[
            _ServiceRow(
              imageUrl: item.imageUrl,
              title: item.name,
              date: item.eventDate,
              time: '${item.startTime} - ${item.endTime}',
            ),
            const SizedBox(height: 12),
          ],

          _Footer(
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

class _Header extends StatelessWidget {
  final String status;
  final int id;

  const _Header({required this.status, required this.id});

  @override
  Widget build(BuildContext context) {
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
        _StatusBadge(status: status),
      ],
    );
  }
}


class _ServiceRow extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String date;
  final String time;

  const _ServiceRow({
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: AppColor.lightGrey.withOpacity(0.3),
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.blueFont,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$date • $time',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColor.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _Footer extends StatelessWidget {
  final double total;
  final VoidCallback onViewDetails;
  final bool showCancel;
  final VoidCallback? onCancel;

  const _Footer({
    required this.total,
    required this.onViewDetails,
    required this.showCancel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'EGP ${total.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColor.primary,
          ),
        ),
        const Spacer(),
        if (showCancel && onCancel != null)
          TextButton(
            onPressed: () {
              AppAlerts.showPopup(
                context,
                'Booking cancelled successfully',
              );
              onCancel!();
            },
            child: const Text('Cancel'),
          ),
        ElevatedButton(
          onPressed: onViewDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('View'),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

