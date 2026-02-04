import 'package:eventak/customer-UI/features/event_management/event_dashboard/view/event_dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/booking/bookings/view/bookings_list_view.dart';

class HomeActionButtons extends StatelessWidget {
  const HomeActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Expanded(
            child: _buildThinButton(
              context,
              label: "My Bookings",
              icon: Icons.confirmation_number_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookingsListView()),
              ),
            ),
          ),
          const SizedBox(width: 12), // Space between buttons
          
          Expanded(
            child: _buildThinButton(
              context,
              label: "My Events",
              icon: Icons.celebration,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventDashboardView()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppColor.primary),
      label: Text(
        label,
        style: TextStyle(
          color: AppColor.blueFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: AppColor.primary.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColor.primary.withOpacity(0.05),
      ),
    );
  }
}