import 'dart:async';
import 'package:eventak/auth/data/user_provider.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:eventak/customer-UI/features/booking/checkout/data/checkout_service.dart';
import 'package:eventak/customer-UI/features/booking/checkout/widgets/booking_notes_section.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_item_tile.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_summary.dart';
import 'package:eventak/shared/main_viewed_page.dart'; 
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/shared/prev_page_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  bool _isListExpanded = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout(CartProvider cart) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = (prefs.getString('auth_token') ?? '').replaceAll('"', '');

      if (token.isEmpty) throw Exception("Session expired. Please login again.");

      final checkoutService = CheckoutService();
      final response = await checkoutService.createBooking(
        token: token,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        pointsRedeemed: cart.pointsRedeemed > 0 ? cart.pointsRedeemed : null,
        promocode: cart.appliedPromo,
      );

      Navigator.of(context, rootNavigator: true).pop();

      if (mounted) {
        await context.read<UserProvider>().refreshUser();
        await cart.clearCart();
        
        _showPaymentDialog(response);
      }
    } catch (e) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      AppAlerts.showPopup(context, e.toString().replaceAll("Exception: ", ""), isError: true);
    }
  }

  void _showPaymentDialog(CheckoutResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Booking Successful", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Booking #${response.booking.id} has been created. Would you like to pay now to confirm your booking?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainPage()),
                (route) => false,
              );
            },
            child: Text("Pay Later", style: TextStyle(color: AppColor.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
            onPressed: () async {
              if (response.paymentUrl != null) {
                final Uri url = Uri.parse(response.paymentUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              }
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("Pay Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const CustomHomeAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const PrevPageButton(),
                const SizedBox(width: 12),
                Text('Checkout', style: TextStyle(color: AppColor.blueFont, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isListExpanded = !_isListExpanded),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined, color: AppColor.primary),
                              const SizedBox(width: 12),
                              Text("Order Items (${cart.items.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Icon(_isListExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColor.grey),
                        ],
                      ),
                    ),
                  ),
                  if (_isListExpanded)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) => CartItemTile(item: cart.items[index], isEditMode: false, readOnly: true),
                    ),
                  const SizedBox(height: 20),
                  BookingNotesSection(controller: _notesController),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          CartSummary(
            subtotal: cart.subtotal,
            discount: cart.discount,
            total: cart.total,
            appliedPromo: cart.appliedPromo,
            pointsDiscount: cart.pointsDiscount,
            pointsRedeemed: cart.pointsRedeemed,
            buttonText: "Confirm Booking",
            onPressed: () => _handleCheckout(cart),
            isCheckout: true,
            pointsController: null,
            userLoyaltyPoints: cart.userLoyaltyPoints,
          ),
        ],
      ),
    );
  }
}