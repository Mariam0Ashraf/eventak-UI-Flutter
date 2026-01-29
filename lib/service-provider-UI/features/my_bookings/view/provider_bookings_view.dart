import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/provider_booking_service.dart';
import '../data/provider_booking_model.dart';
import '../widgets/provider_booking_card.dart';

class ProviderBookingsView extends StatefulWidget {
  const ProviderBookingsView({super.key});

  @override
  State<ProviderBookingsView> createState() => _ProviderBookingsViewState();
}

class _ProviderBookingsViewState extends State<ProviderBookingsView> {
  final ProviderBookingService _service = ProviderBookingService();
  String _selectedStatus = 'all';
  DateTimeRange? _dateRange;
  late Future<List<ProviderBooking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _bookingsFuture = _service.fetchMyBookings(
        status: _selectedStatus,
        fromDate: _dateRange?.start.toIso8601String().split('T')[0],
        toDate: _dateRange?.end.toIso8601String().split('T')[0],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Bookings"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.tune), onPressed: _showFilterSheet),
        ],
      ),
      body: FutureBuilder<List<ProviderBooking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          
          final List<ProviderBooking> bookings = snapshot.data ?? [];
          if (bookings.isEmpty) return const Center(child: Text("No bookings found"));

          return RefreshIndicator(
            onRefresh: () async => _applyFilters(),
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              itemCount: bookings.length, 
              itemBuilder: (context, index) => ProviderBookingCard(booking: bookings[index]),
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['all', 'pending', 'confirmed', 'completed', 'cancelled'].map((s) {
                  bool isSelected = _selectedStatus == s;
                  return ChoiceChip(
                    label: Text(s.toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 10)),
                    selected: isSelected,
                    selectedColor: AppColor.primary,
                    onSelected: (val) => setSheetState(() => _selectedStatus = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: Text(_dateRange == null ? "Select Date Range" : "Dates Selected"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final picked = await showDateRangePicker(context: context, firstDate: DateTime(2025), lastDate: DateTime(2030));
                  if (picked != null) setSheetState(() => _dateRange = picked);
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () {
                    setState(() { _selectedStatus = 'all'; _dateRange = null; });
                    Navigator.pop(context);
                    _applyFilters();
                  }, child: const Text("Reset"))),
                  Expanded(child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                    onPressed: () { Navigator.pop(context); _applyFilters(); },
                    child: const Text("Apply", style: TextStyle(color: Colors.white)),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}