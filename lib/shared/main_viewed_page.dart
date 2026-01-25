import 'package:flutter/material.dart';
import 'package:eventak/customer-UI/features/home/view/home_view.dart';
import 'package:eventak/customer-UI/features/home/view/search_view.dart';
import 'package:eventak/customer-UI/features/cart/view/cart_view.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/shared/user_bottom_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages for each bottom nav tab
  final List<Widget> _pages = [
    const HomeView(),
    const SearchView(),
    const CartView(),
    const UserProfilePage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (idx) {
          setState(() {
            _selectedIndex = idx;
          });
        },
      ),
    );
  }
}
