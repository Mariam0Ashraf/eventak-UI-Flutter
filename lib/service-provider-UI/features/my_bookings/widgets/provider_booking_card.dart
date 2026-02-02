import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/provider_booking_model.dart';
import '../view/booking_details_view.dart'; 

class ProviderBookingCard extends StatelessWidget {
  final ProviderBooking booking;
  final int index;

  const ProviderBookingCard({
    super.key,
    required this.booking,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Booking #$index",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    _buildStatusBadge(booking.status, booking.statusLabel),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.visibility_outlined, color: AppColor.primary, size: 20),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingDetailsView(bookingId: booking.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            
            ...booking.items.map((item) => _buildItemRow(item)),
            
            const Divider(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount", 
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  "EGP ${booking.total}",
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BookingItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty)
                  ? Image.network(
                      item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                    )
                  : Icon(
                      item.bookableType == 'service_package' 
                          ? Icons.inventory_2_outlined 
                          : Icons.image_not_supported_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${item.bookableType == 'service_package' ? 'Package' : 'Service'} • ${item.eventDate}",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            "EGP ${item.calculatedPrice}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, 
          fontSize: 11, 
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}