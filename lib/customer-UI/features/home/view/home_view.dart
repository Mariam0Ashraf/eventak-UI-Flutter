import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/view/create_event_view.dart';
import 'package:eventak/customer-UI/features/services/list_services/widgets/service_providers_tabs.dart';
import 'package:flutter/material.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/features/home/widgets/home_carousel.dart';
import 'package:eventak/customer-UI/features/home/widgets/home_categories_section.dart';
import 'package:eventak/customer-UI/features/home/widgets/home_providers_section.dart';
import 'package:eventak/customer-UI/features/home/data/home_service.dart';
import 'package:eventak/customer-UI/features/home/view/search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedBottomIndex = 0;
  final HomeService _homeService = HomeService();

  List<Map<String, dynamic>> _apiServiceCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<Map<String, String>> carouselItems = const [
    {
      'title': 'Wedding Packages',
      'img': 'assets/App_photos/carousel_wedding.png',
    },
    {
      'title': 'Birthday Packages',
      'img': 'assets/App_photos/carousel_birthday.png',
    },
    {
      'title': 'Graduation Party Packages',
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
            MaterialPageRoute(builder: (context) => const SearchView()),
          );
        },
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search, color: AppColor.blueFont),
          filled: true,
          fillColor: AppColor.background,
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

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: HomeCarousel(
              carouselItems: carouselItems, 
            ),
          ),


          HomeCategoriesSection(categories: categories),

          // inside _HomeViewState in home_view.dart

          HomeProvidersSection(
            apiServiceCategories: _apiServiceCategories,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            // inside HomeView onViewAll
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllServicesTabsView(
                    categories: _apiServiceCategories,
                    initialIndex: -1, // opening the "All" tab
                  ),
                ),
              );
            },
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
      /*bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemSelected: (idx) {
          setState(() {
            _selectedBottomIndex = idx;
          });
        },
      ),*/

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
