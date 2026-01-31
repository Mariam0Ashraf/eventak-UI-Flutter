import 'package:eventak/customer-UI/features/booking/bookings/widgets/booking_card.dart';
import 'package:eventak/customer-UI/features/booking/bookings/widgets/empty_bookings_state.dart';
import 'package:eventak/customer-UI/features/booking/checkout/data/booking_model.dart';
import 'package:flutter/material.dart';

class BookingsListView extends StatelessWidget {
  final List<Booking> bookings;
  final void Function(Booking booking) onBookingTap;
  final void Function(Booking booking)? onCancelBooking;

  const BookingsListView({
    super.key,
    required this.bookings,
    required this.onBookingTap,
    this.onCancelBooking,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const EmptyBookingsState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];

        return BookingCard(
          booking: booking,
          onViewDetails: () => onBookingTap(booking),
          onCancel: booking.status == 'pending' && onCancelBooking != null
              ? () => onCancelBooking!(booking)
              : null,
        );
      },
    );
  }
}
