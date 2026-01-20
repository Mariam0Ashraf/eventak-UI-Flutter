import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Slidable(
      key: ValueKey(item.cartItemId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.18, 
        children: [
          CustomSlidableAction(
            onPressed: (_) => cart.removeItem(item),
            backgroundColor: Colors.transparent,
            child: Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // IMAGE
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColor.beige,
              backgroundImage:
                  item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
              child: item.imageUrl == null
                  ? Icon(
                      Icons.image,
                      size: 20,
                      color: AppColor.primary,
                    )
                  : null,
            ),


            const SizedBox(width: 12),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.blueFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Notes
                  if (item.options['notes'] != null &&
                      item.options['notes'].toString().isNotEmpty)
                    Text(
                      item.options['notes'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),

                  const SizedBox(height: 6),

                  // PRICE
                  Text(
                    '${item.price} EGP',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // QUANTITY 
            Row(
              children: [
                _quantityBtn(
                  icon: Icons.remove,
                  onPressed: item.quantity > 1
                      ? () => cart.updateItemQuantity(
                            item,
                            item.quantity - 1,
                          )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                _quantityBtn(
                  icon: Icons.add,
                  onPressed: () => cart.updateItemQuantity(
                    item,
                    item.quantity + 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityBtn({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: AppColor.primary,
        ),
      ),
    );
  }
}
