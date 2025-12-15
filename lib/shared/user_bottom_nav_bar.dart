// lib/shared/app_bottom_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
// Note: We need to import the views being navigated to 
import 'package:eventak/auth/view/profile_view.dart';
// Add imports for Search, Cart, Notifications views here as needed

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
        onItemSelected(idx);

        if (idx == 4) {
          // Handle navigation specific to the Profile tab (index 4)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserProfilePage()),
          );
        }
        // Add logic for other index navigations here if they require Navigator.push,
        // or let a higher-level routing handler handle the index change.
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