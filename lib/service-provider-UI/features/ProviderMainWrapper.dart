import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/customer-UI/features/home/view/search_view.dart';
import 'package:eventak/service-provider-UI/features/my_bookings/view/provider_bookings_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/views/service_provider_home_view.dart';

class ProviderMainWrapper extends StatefulWidget {
  const ProviderMainWrapper({super.key});

  @override
  State<ProviderMainWrapper> createState() => _ProviderMainWrapperState();
}

class _ProviderMainWrapperState extends State<ProviderMainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ServiceProviderHomeView(),
    const SearchView (), 
    const ProviderBookingsView(),
    const UserProfilePage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColor.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}