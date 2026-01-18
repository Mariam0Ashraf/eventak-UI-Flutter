import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_item_tile.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_summary.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_service.dart';
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
    // This triggers the fetch using the token stored in SharedPreferences
    Future.microtask(() {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watches the global provider for changes (loading, items, etc.)
    final cart = context.watch<CartProvider>();

    return Scaffold(
    backgroundColor: AppColor.background,
    appBar: AppBar(
      backgroundColor: Colors.transparent, 
      elevation: 0,
      title: Text(
        'My Cart',
        style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold),
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
                      Expanded(
                        child: ListView.builder(
                          itemCount: cart.items.length,
                          itemBuilder: (_, index) => CartItemTile(item: cart.items[index]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        child: TextField(
                          controller: _notesController,
                        minLines: 3, 
                        maxLines: 5, 
                        keyboardType: TextInputType.multiline, 
                        decoration: InputDecoration(
                            hintText: "Add notes for your event...",
                            prefixIcon: Icon(Icons.note_add_outlined, color: AppColor.primary),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      CartSummary(total: cart.total),
                    ],
                  ),
      );
      
  }
}