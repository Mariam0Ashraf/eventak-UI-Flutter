import 'dart:async';

import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import 'package:eventak/customer-UI/features/booking/checkout/data/checkout_service.dart';
import 'package:eventak/customer-UI/features/booking/checkout/widgets/booking_notes_section.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_item_tile.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_summary.dart';
import 'package:eventak/customer-UI/features/home/view/home_view.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/shared/prev_page_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Show loading dialog 
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      //  Get auth token
      final prefs = await SharedPreferences.getInstance();
      final rawToken = prefs.getString('auth_token') ?? '';
      final token = rawToken.replaceAll('"', '');

      if (token.isEmpty) {
        throw Exception("Authentication session expired. Please login again.");
      }

      //  Call checkout service
      final checkoutService = CheckoutService();
      final booking = await checkoutService.createBooking(
        token: token,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
        pointsRedeemed: cart.pointsRedeemed > 0
            ? cart.pointsRedeemed
            : null,
        promocode: cart.appliedPromo,
      );
      // Close loading dialog 
      Navigator.of(context, rootNavigator: true).pop();

      // Show success mouse
      AppAlerts.showPopup(
        context,
        "Booking #${booking.id} done successfully!\nPay to confirm your booking, please!",
        isError: false,
      );

      // Clear cart
      await cart.clearCart();

      // Navigate to Home (clean stack of the navigator )
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeView()),
          (route) => false,
        );
      });

    } catch (e) {
      // Always close loader if something fails
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      debugPrint("Checkout Error: $e");

      // Show error popup
      AppAlerts.showPopup(
        context,
        e.toString().replaceAll("Exception: ", ""),
        isError: true,
      );
    }
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
                Text(
                  'Checkout',
                  style: TextStyle(
                    color: AppColor.blueFont,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Toggle Button for Items
                  GestureDetector(
                    onTap: () => setState(() => _isListExpanded = !_isListExpanded),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined, color: AppColor.primary),
                              const SizedBox(width: 12),
                              Text(
                                "Order Items (${cart.items.length})",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Icon(
                            _isListExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: AppColor.grey,
                          ),
                        ],
                      ),
                    ),
                  ),

                  ///  Collapsible List
                  if (_isListExpanded)
                    ListView.builder(
                      shrinkWrap: true, // Crucial for use inside SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        return CartItemTile(
                          item: cart.items[index],
                          isEditMode: false,
                          readOnly: true,
                        );
                      },
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
            discount: cart.discount , 
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