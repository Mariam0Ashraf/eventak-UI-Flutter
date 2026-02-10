import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import '../data/provider_booking_model.dart';
import '../data/provider_booking_service.dart';

class BookingDetailsView extends StatefulWidget {
  final int bookingId;
  const BookingDetailsView({super.key, required this.bookingId});

  @override
  State<BookingDetailsView> createState() => _BookingDetailsViewState();
}

class _BookingDetailsViewState extends State<BookingDetailsView> {
  final ProviderBookingService _service = ProviderBookingService();
  late Future<ProviderBooking> _detailsFuture;
  bool _isCustomer = false; 

  @override
  void initState() {
    super.initState();
    _checkRole();
    _detailsFuture = _service.fetchBookingDetails(widget.bookingId);
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? prefs.getString('user_type'); 
    setState(() {
      _isCustomer = role?.toLowerCase() == 'customer';
    });
  }

  Future<void> _handlePayment(ProviderBooking booking) async {
    String? paymentUrl;
    try {
      if (booking.transactions.isNotEmpty) {
        final paymentTx = booking.transactions.firstWhere(
          (t) => t['type'].toString().toLowerCase() == 'payment',
          orElse: () => booking.transactions.first,
        );

        final meta = paymentTx['meta'];
        if (meta != null && meta['payment_link_response'] != null) {
          paymentUrl = meta['payment_link_response']['shorten_url']?.toString() ?? 
                       meta['payment_link_response']['client_url']?.toString();
        }
      }
    } catch (e) {
      debugPrint("Payment Error: $e");
    }

    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      final Uri uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) AppAlerts.showPopup(context, "Could not open browser", isError: true);
      }
    } else {
      if (mounted) AppAlerts.showPopup(context, "Payment link not found", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: Text("Booking Details", style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<ProviderBooking>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          final booking = snapshot.data!;
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusCard(booking),
              const SizedBox(height: 24),
              const Text("Booked Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...booking.items.map((item) => _buildItemDetailCard(item)),
              const SizedBox(height: 24),
              _buildPriceSummary(booking),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(ProviderBooking booking) {
    final bool isPending = booking.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ID: #${booking.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildStatusBadge(booking.status, booking.statusLabel),
                  if (isPending && _isCustomer) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _handlePayment(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Pay Now", 
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          _rowInfo("Created At", booking.createdAt, icon: Icons.calendar_today),
          if (booking.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text("Notes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(booking.notes, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
          ]
        ],
      ),
    );
  }
  
  Widget _buildItemDetailCard(BookingItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.thumbnailUrl != null 
              ? Image.network(item.thumbnailUrl!, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholderImage())
              : _placeholderImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(item.bookableType.replaceAll('_', ' ').toUpperCase(), 
                  style: TextStyle(color: AppColor.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Date: ${item.eventDate}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("EGP ${item.calculatedPrice}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(ProviderBooking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColor.primary, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Amount", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
          Text("EGP ${booking.total}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 70, height: 70, color: Colors.grey.shade100, 
      child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
    );
  }

  Widget _buildStatusBadge(String status, String label) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed': color = Colors.blue; break;
      case 'pending': color = Colors.orange; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}