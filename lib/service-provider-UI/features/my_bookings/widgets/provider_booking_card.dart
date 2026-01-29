import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/provider_booking_model.dart';

class ProviderBookingCard extends StatelessWidget {
  final ProviderBooking booking;
  const ProviderBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
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
                Text("Booking #${booking.id}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildStatusBadge(booking.status, booking.statusLabel),
              ],
            ),
            const Divider(height: 24),
            ...booking.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipOval( 
                    child: Image.network(item.thumbnailUrl, 
                        width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Container(width: 50, height: 50, color: Colors.grey.shade200, child: const Icon(Icons.broken_image))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text("Date: ${item.eventDate}", 
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text("EGP ${item.calculatedPrice}", 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal", style: TextStyle(color: Colors.grey)),
                Text("EGP ${booking.total}", 
                    style: TextStyle(color: AppColor.primary, 
                    fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color color = status == 'pending' ? Colors.orange : (status == 'cancelled' ? Colors.red : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}