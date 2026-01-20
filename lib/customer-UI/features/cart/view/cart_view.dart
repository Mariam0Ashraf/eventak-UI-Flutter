import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_item_tile.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_summary.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/shared/prev_page_button.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (!cart.isLoading && !cart.isEmpty) {
      for (var item in cart.items) {
        debugPrint(
          'Item: ${item.name}, Quantity: ${item.quantity}, Notes: ${item.options['notes']}, Image: ${item.imageUrl}'
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Cart',
          style: TextStyle(
              color: AppColor.blueFont, fontWeight: FontWeight.bold),
        ),
        leading: const PrevPageButton(),
        actions: [
          if (!cart.isEmpty)
            TextButton.icon(
              onPressed: cart.clearCart,
              icon: Icon(Icons.delete_sweep, color: Colors.red[400], size: 20),
              label: Text("Clear Cart", style: TextStyle(color: Colors.red[400])),
            ),
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                  children: [
                    // Cart Items List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: cart.items.length,
                        itemBuilder: (_, index) =>
                            CartItemTile(item: cart.items[index]),
                      ),
                    ),

                    // Notes Box
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: IntrinsicHeight(
                        child: TextField(
                          controller: _notesController,
                          minLines: 2,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: "Add Notes...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ),

                    // Cart Summary (Total + Checkout)
                    CartSummary(total: cart.total),
                  ],
                ),
    );
  }
}
