// lib/customer-UI/features/home/view/home_view.dart

import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/event_management/view/create_event_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/widgets/home_carousel.dart';
import 'package:eventak/customer-UI/widgets/home_categories_section.dart';
import 'package:eventak/customer-UI/widgets/home_providers_section.dart';
import 'package:eventak/customer-UI/features/home/data/home_service.dart';
import 'package:eventak/shared/user_bottom_nav_bar.dart';
import 'package:eventak/customer-UI/features/home/view/search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedBottomIndex = 0;
  final HomeService _homeService = HomeService();

  // State for API data
  List<Map<String, dynamic>> _apiServiceCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Local Data (Moved out of build)
  final List<Map<String, String>> carouselItems = const [
    {
      'title': 'Wedding Package',
      'img': 'assets/App_photos/carousel_wedding.png',
    },
    {
      'title': 'Birthday Package',
      'img': 'assets/App_photos/carousel_birthday.png',
    },
    {
      'title': 'Graduation Party Package',
      'img': 'assets/App_photos/Graduation.jpg',
    },
  ];

  final List<Map<String, String>> categories = const [
    {'label': 'Wedding', 'img': 'assets/App_photos/wedding.jpg'},
    {'label': 'Birthday', 'img': 'assets/App_photos/Birthday-Cake-1.webp'},
    {'label': 'Seminar', 'img': 'assets/App_photos/Siminars.jpg'},
    {'label': 'Graduation', 'img': 'assets/App_photos/Graduation.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final categoriesResult = await _homeService.getServiceCategories();
      // Only fetch packages if needed later

      setState(() {
        _apiServiceCategories = categoriesResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching data: $e');
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
        readOnly: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search, color: AppColor.blueFont),
          filled: true,
          fillColor: AppColor.beige,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 6),

          // --- Isolated Widgets Used Here ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: HomeCarousel(carouselItems: carouselItems),
          ),

          HomeCategoriesSection(categories: categories),

          HomeProvidersSection(
            apiServiceCategories: _apiServiceCategories,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHomeAppBar(),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemSelected: (idx) {
          // Update the state when an item is tapped
          setState(() {
            _selectedBottomIndex = idx;
          });
          // Note: Specific navigation logic for push/replace is handled
          // inside AppBottomNavBar or should be moved to a router.
        },
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: "Create Event",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventView()),
          );
        },
        backgroundColor: AppColor.primary,
        hoverColor: AppColor.secondaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
