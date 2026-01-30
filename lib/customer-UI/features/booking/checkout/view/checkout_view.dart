import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/booking/checkout/widgets/booking_notes_section.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_item_tile.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_summary.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/shared/prev_page_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: const CustomHomeAppBar(),
      body: Column(
        children: [
          /// 1. Navigation Header
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
                  /// 2. Toggle Button for Items
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

                  /// 3. Collapsible List
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

                  /// 4. Booking Notes Section
                  BookingNotesSection(controller: _notesController),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// 5. Fixed Summary
          /*CartSummary(
            subtotal: cart.subtotal,
            discount: cart.discount,
            total: cart.total,
            appliedPromo: cart.appliedPromo,
            pointsDiscount: cart.pointsDiscount,
            pointsRedeemed: cart.pointsRedeemed,
            buttonText: "Checkout Now",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutView()),
              );
            }, 
            pointsController: _pointsController, 
                        onApplyPoints: () {
                          final pts = int.tryParse(_pointsController.text) ?? 0;
                          // cart.applyPoints(pts); // You'll implement this in your provider
                        },
                        userLoyaltyPoints: cart.userLoyaltyPoints,
            //totalUserPoints: 500, // Replace with your actual points variable
          ),*/
        ],
      ),
    );
  }
}