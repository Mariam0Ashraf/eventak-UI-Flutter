import 'package:eventak/customer-UI/features/cart/widgets/update_cart_item_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_item_model.dart';
import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback? onTap;

  const CartItemTile({
    super.key,
    required this.item,
    this.isEditMode = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    
    final String? eventDate = item.options['event_date'];
    final String? startTime = item.options['start_time'];
    final String? endTime = item.options['end_time'];
    final String? notes = item.options['notes'];

    return Slidable(
      key: ValueKey(item.cartItemId),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          CustomSlidableAction(
            onPressed: (_) => cart.removeItem(item),
            backgroundColor: Colors.transparent,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
              child: const Icon(Icons.delete, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => UpdateCartItemSheet(item: item), 
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: isSelected ? Border.all(color: AppColor.primary, width: 2) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColor.beige,
                backgroundImage: item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
                child: item.imageUrl == null ? Icon(Icons.celebration, color: AppColor.primary) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            color: AppColor.blueFont, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          ),
                        ),
                        Text(
                          '${item.price} EGP', 
                          style: TextStyle(
                            color: AppColor.primary, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    if (eventDate != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_month, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            "$eventDate | ${startTime ?? ''} - ${endTime ?? ''}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),

                    if (item.capacity != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "Capacity: ${item.capacity} Persons",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),

                    if (notes != null && notes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Note: $notes",
                            style: TextStyle(fontSize: 11, color: Colors.grey[700], fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}