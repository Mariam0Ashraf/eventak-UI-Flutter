import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventak/core/constants/app-colors.dart'; 
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import this

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Slidable(
      key: ValueKey(item.cartItemId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (_) => cart.removeItem(item),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: BorderRadius.circular(15),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            // Image Loading logic
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                /*child: Image.network(
                  // ACCESSING VIA OPTION B: Nested object
                  item.service?.imageUrl ?? 'https://via.placeholder.com/150', 
                  height: 75,
                  width: 75,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 75,
                    width: 75,
                    color: AppColor.beige,
                    child: Icon(Icons.image_not_supported, color: AppColor.primary),
                  ),
                ),*/
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${item.price} EGP', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // Quantity buttons...
            Row(
              children: [
                _quantityBtn(Icons.remove, () => cart.updateItemQuantity(item, item.quantity - 1)),
                Text(" ${item.quantity} "),
                _quantityBtn(Icons.add, () => cart.updateItemQuantity(item, item.quantity + 1)),
              ],
            )
          ],
        ),
      ),
    );
  }


  Widget _quantityBtn(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColor.primary),
      ),
    );
  }
}