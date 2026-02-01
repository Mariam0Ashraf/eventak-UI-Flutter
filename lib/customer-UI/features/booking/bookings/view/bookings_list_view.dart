import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:eventak/customer-UI/features/booking/bookings/data/bookings_provider.dart';
import 'package:eventak/customer-UI/features/booking/bookings/widgets/booking_card.dart';
import 'package:eventak/customer-UI/features/booking/bookings/widgets/empty_bookings_state.dart';
import 'package:eventak/customer-UI/features/booking/checkout/data/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum BookingSort { date, id }

class BookingsListView extends StatefulWidget {
  const BookingsListView({super.key});

  @override
  State<BookingsListView> createState() => _BookingsListViewState();
}

class _BookingsListViewState extends State<BookingsListView> {
  BookingSort _currentSort = BookingSort.date;
  bool _isDescending = true;
  bool _showOnlyPending = false;

  @override
  void initState() {
    super.initState();
    // Load bookings on entry
    Future.microtask(() => context.read<BookingsProvider>().loadBookings());
  }

  Future<void> _handleCancel(BuildContext context, Booking booking) async {
    final provider = context.read<BookingsProvider>();
    
    // Show Confirmation Dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel Booking #${booking.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await provider.cancelBooking(booking.id);
        if (context.mounted) {
          AppAlerts.showPopup(
            context, 
            'Booking #${booking.id} cancelled successfully'
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppAlerts.showPopup(
            context, 
            'Failed to cancel booking', 
            isError: true
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingsProvider>();
    
    // Logic to identify pending bookings for the header count
    final pendingBookings = provider.bookings.where((b) => b.status.toLowerCase() == 'pending').toList();
    // Filter the list based on user selection
    List<Booking> displayList = _showOnlyPending 
        ? pendingBookings 
        : List.from(provider.bookings);
    //  Sort the list
    displayList.sort((a, b) {
      int cmp;
      if (_currentSort == BookingSort.date) {
        String dateA = a.items.isNotEmpty ? a.items.first.eventDate : '';
        String dateB = b.items.isNotEmpty ? b.items.first.eventDate : '';
        cmp = dateA.compareTo(dateB);
      } else {
        cmp = a.id.compareTo(b.id);
      }
      return _isDescending ? -cmp : cmp;
    });

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Bookings',
          style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: AppColor.blueFont),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(pendingBookings.length),
                Expanded(
                  child: provider.bookings.isEmpty
                      ? const EmptyBookingsState()
                      : displayList.isEmpty && _showOnlyPending
                          ? _buildNoFilteredResults()
                          : RefreshIndicator(
                              onRefresh: () => provider.loadBookings(),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  final booking = displayList[index];
                                  return BookingCard(
                                    booking: booking,
                                    onViewDetails: () {
                                      // TODO: Navigate to Detail Screen
                                    },
                                    onCancel: () => _handleCancel(context, booking),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(int pendingCount) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Left: Pending Filter Card
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showOnlyPending = !_showOnlyPending),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _showOnlyPending ? Colors.orange.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _showOnlyPending ? Colors.orange : Colors.transparent,
                    width: 1.5,
                  ),
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
                    Row(
                      children: [
                        Text(
                          '$pendingCount Pending',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _showOnlyPending ? Colors.orange.shade900 : AppColor.blueFont,
                          ),
                        ),
                        if (_showOnlyPending) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.cancel, size: 16, color: Colors.orange),
                        ]
                      ],
                    ),
                    Text(
                      _showOnlyPending ? 'Viewing unpaid only' : 'Pay to confirm (Tap to filter unpaid)',
                      style: TextStyle(fontSize: 11, color: AppColor.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),

          // Right: Sorting Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                PopupMenuButton<BookingSort>(
                  initialValue: _currentSort,
                  tooltip: 'Sort by',
                  icon: Icon(Icons.sort_rounded, color: AppColor.primary),
                  onSelected: (sort) => setState(() => _currentSort = sort),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: BookingSort.date, child: Text("By Date")),
                    const PopupMenuItem(value: BookingSort.id, child: Text("By Booking #")),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isDescending ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 20,
                    color: AppColor.primary,
                  ),
                  onPressed: () => setState(() => _isDescending = !_isDescending),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilteredResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("No pending bookings found"),
          TextButton(
            onPressed: () => setState(() => _showOnlyPending = false),
            child: const Text("Show all bookings"),
          )
        ],
      ),
    );
  }
}