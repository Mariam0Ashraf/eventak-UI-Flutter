import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:provider/provider.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemSelected,
      selectedItemColor: AppColor.primary,
      unselectedItemColor: AppColor.blueFont.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      // Standardize icon size
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),

        // --- CHATBOT ICON ---
        const BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome),
          label: 'Assistant',
        ),

        BottomNavigationBarItem(
          icon: Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.blueGrey,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          label: 'Cart',
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}