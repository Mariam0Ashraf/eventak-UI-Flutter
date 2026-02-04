import 'package:eventak/customer-UI/features/chat_bot/view/chatbot_view.dart';
import 'package:eventak/customer-UI/features/event_management/event_dashboard/view/event_dashboard_view.dart';
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

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5, (index) => GlobalKey<NavigatorState>()
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final navigator = _navigatorKeys[_selectedIndex].currentState;
        if (navigator != null && await navigator.maybePop()) {
          return;
        }

        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } 
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildTab(0, const HomeView()),
            _buildTab(1, const SearchView()),
            _buildTab(2, const ChatbotView()),
            _buildTab(3, const CartView()),
            //_buildTab(, const EventDashboardView() ), // Tab 3 placeholder
            _buildTab(4, const UserProfilePage()), // Tab 4 Profile
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemSelected: (idx) {
            
            if (idx == _selectedIndex) {
              _navigatorKeys[idx].currentState?.popUntil((r) => r.isFirst);
            } else {
              setState(() => _selectedIndex = idx);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTab(int index, Widget view) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => view),
    );
  }
}

