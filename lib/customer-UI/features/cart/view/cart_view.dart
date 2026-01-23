import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:eventak/customer-UI/features/cart/widgets/cart_item_tile.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_summary.dart';
import 'package:eventak/customer-UI/features/cart/widgets/update_cart_item_sheet.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/shared/prev_page_button.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool isEditMode = false;
  CartItem? editingItem;

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

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Cart',
          style: TextStyle(
            color: AppColor.blueFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const PrevPageButton(),
        actions: [
          if (!cart.isEmpty) ...[
            IconButton(
              icon: Icon(
                Icons.edit,
                color: isEditMode ? AppColor.primary : AppColor.grey,
              ),
              onPressed: () {
                setState(() {
                  isEditMode = !isEditMode;
                  editingItem = null; 
                });
              },
            ),
            TextButton.icon(
              onPressed: () => cart.clearCart(),
              icon: Icon(Icons.delete_sweep, color: Colors.red[400], size: 20),
              label: Text(
                "Clear",
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
          ],
        ],
      ),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                  children: [
                    // Helper Hint
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        isEditMode 
                          ? 'Tap an item to edit details' 
                          : '← Swipe left to delete an item',
                        style: TextStyle(
                          fontSize: 12,
                          color: isEditMode ? AppColor.primary : Colors.grey[600],
                          fontWeight: isEditMode ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: cart.items.length,
                        itemBuilder: (_, index) {
                          final item = cart.items[index];
                          return CartItemTile(
                            item: item,
                            isEditMode: isEditMode,
                            isSelected: editingItem?.cartItemId == item.cartItemId,
                            onTap: () {
                              
                              if (isEditMode) {
                                setState(() {
                                  editingItem = item;
                                });
                                
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (_) => UpdateCartItemSheet(item: item),
                                ).then((_) {
                                  setState(() {
                                    editingItem = null;
                                  });
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),

                    if (editingItem == null) 
                      CartSummary(total: cart.total),
                    
                    const SizedBox(height: 16),
                  ],
                ),
    );
  }
}
