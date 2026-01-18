// lib/shared/app_bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
// Note: We need to import the views being navigated to
import 'package:eventak/auth/view/profile_view.dart';
// imports for Search, Cart, Notifications views here as needed
import 'package:eventak/customer-UI/features/home/view/search_view.dart';
import 'package:eventak/customer-UI/features/cart/view/cart_view.dart';


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
      onTap: (idx) {
        // 1. Only update the index if it's the Home tab (index 0)
        // This keeps the "Home" icon blue even when you click others to navigate
        if (idx == 0) {
          onItemSelected(idx);
        }

        // 2. Just perform the navigation for others
        switch (idx) {
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchView()));
            break;
          case 2: 
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartView()));
            break;
          case 4:
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UserProfilePage()));
            break;
        }
      },

      selectedItemColor: AppColor.primary,
      unselectedItemColor: AppColor.blueFont.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}
