import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/booking/bookings/view/bookings_list_view.dart';
import 'package:eventak/customer-UI/features/event_management/create_event/view/create_event_view.dart';
import 'package:eventak/customer-UI/features/services/list_services/widgets/service_providers_tabs.dart';
import 'package:flutter/material.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/features/home/widgets/home_carousel.dart';
import 'package:eventak/customer-UI/features/home/widgets/event_categories_section.dart';
import 'package:eventak/customer-UI/features/home/widgets/home_providers_section.dart';
import 'package:eventak/customer-UI/features/home/data/home_service.dart';
import 'package:eventak/customer-UI/features/home/view/search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeService _homeService = HomeService();

  List<Map<String, dynamic>> _apiServiceTypes = [];
  List<Map<String, dynamic>> _apiCategories = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final results = await Future.wait([
        _homeService.getServiceTypes(),
        _homeService.getServiceCategories(),
      ]);

      setState(() {
        _apiServiceTypes = results[0];
        _apiCategories = results[1];
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
    List<Map<String, String>> carouselData = _apiCategories.map((cat) {
      return {
        'title': '${cat['name'] ?? ''} Packages',
        'img': (cat['image_url'] ?? '').toString(),
        'raw_name': (cat['name'] ?? '').toString(),
      };
    }).toList();

    // 2. Sort to ensure "Wedding" is 1st index and other last index
    carouselData.sort((a, b) {
      if (a['title']!.toLowerCase().contains('wedding')) return -1;
      if (b['title']!.toLowerCase().contains('wedding')) return 1;

      if (a['title']!.toLowerCase().contains('other')) return 1;
      if (b['title']!.toLowerCase().contains('other')) return -1;

      return 0;
    });
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: HomeCarousel(carouselItems: carouselData, apiCategories:_apiCategories ),
          ),
          HomeProvidersSection(
            apiServiceTypes: _apiServiceTypes,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllServicesTabsView(
                    categories: _apiServiceTypes,
                    initialIndex: -1, // opening the "All" tab
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          EventCategoriesSection(
            categories: _apiCategories,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 24),

          // till we add bookings button in the side bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingsListView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: AppColor.background,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'View My Bookings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHomeAppBar(),
      body: _buildBody(),

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
