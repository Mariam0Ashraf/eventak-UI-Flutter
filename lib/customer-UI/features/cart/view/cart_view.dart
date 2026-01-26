import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_item_tile.dart';
import 'package:eventak/customer-UI/features/cart/widgets/cart_summary.dart';
import 'package:eventak/customer-UI/features/cart/widgets/update_cart_item_sheet.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
//import 'package:eventak/shared/prev_page_button.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  bool isEditMode = false;
  CartItem? editingItem;
  final TextEditingController _promoController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _handleApplyPromo(CartProvider cart) async {
    if (_promoController.text.isEmpty) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      await cart.applyPromocode(_promoController.text.trim());
      
      if (cart.appliedPromo == null) {
        setState(() {
          _errorMessage = "Invalid promocode";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Invalid promocode";
      });
    }
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
        //leading: const PrevPageButton(),
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
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (_) =>
                                      UpdateCartItemSheet(item: item),
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
                    if (editingItem == null) ...[
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: TextField(
                                  controller: _promoController,
                                  onChanged: (_) {
                                    if (_errorMessage != null) {
                                      setState(() {
                                        _errorMessage = null;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Enter Promocode",
                                    hintStyle: const TextStyle(fontSize: 14),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    suffixIcon: cart.appliedPromo != null
                                        ? const Icon(Icons.check_circle,
                                            color: Colors.green)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => _handleApplyPromo(cart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                              ),
                              child: const Text("Apply"),
                            ),
                          ],
                        ),
                      ),
                      CartSummary(
                        subtotal: cart.subtotal,
                        discount: cart.discount,
                        total: cart.total,
                        appliedPromo: cart.appliedPromo,
                      ),
                    ],
                    const SizedBox(height: 4),
                  ],
                ),
    );
  }
}