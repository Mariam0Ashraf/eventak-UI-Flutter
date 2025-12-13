import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/customer-UI/features/event_management/view/create_event_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/features/services/view/providers_list_view.dart';
import 'package:eventak/customer-UI/features/home/data/home_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedBottomIndex = 0;
  int _carouselIndex = 0;
  //int _selectedTab = 0; // 0: Favorites, 1: History, 2: Following
  final PageController _pageController = PageController(viewportFraction: 0.92);
  final HomeService _homeService = HomeService();
  List<Map<String, dynamic>> _apiServiceCategories = [];
  List<Map<String, dynamic>> _apiPackages = [];
  bool _isLoading = true;
  String? _errorMessage;
  /*final List<Map<String, String>> carouselItems = [
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
  ];*/

  final List<Map<String, String>> categories = [
    {'label': 'Wedding', 'img': 'assets/App_photos/wedding.jpg'},
    {'label': 'Birthday', 'img': 'assets/App_photos/Birthday-Cake-1.webp'},
    {'label': 'Seminar', 'img': 'assets/App_photos/Siminars.jpg'},
    {'label': 'Graduation', 'img': 'assets/App_photos/Graduation.jpg'},
  ];

  /*final List<Map<String, String>> serviceProviders = [
    {'label': 'Photographers', 'img': 'assets/App_photos/photographer.png'},
    {'label': 'Venues', 'img': 'assets/App_photos/Venues.jpg'},
    {'label': 'Catering', 'img': 'assets/App_photos/Catering.jpg'},
    {'label': 'Decor', 'img': 'assets/App_photos/decoration.jpg'},
  ];*/

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    try {
      final categoriesResult = await _homeService.getServiceCategories();
      final packagesResult = await _homeService.getPackages();

      setState(() {
        _apiServiceCategories = categoriesResult;
        _apiPackages = packagesResult;
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /*Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: AppColor.blueFont),
        onPressed: () => debugPrint('menu tapped'),
      ),
      title: Image.network(
        'assets/App_photos/eventak_logo.png',
        height: 40, // adjust as needed
        fit: BoxFit.contain,
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
        ),
      ],
    );
  }*/

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: TextField(
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

  /* Widget _buildTabs() {
    final tabs = ['Favorites', 'History', 'Following'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedTab == i;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColor.primary.withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColor.primary.withOpacity(0.12),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        i == 0
                            ? Icons.favorite_border
                            : (i == 1 ? Icons.history : Icons.person_add),
                        color: isSelected ? Colors.white : AppColor.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tabs[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColor.blueFont,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }*/

  Widget _buildCarousel() {
    return SizedBox(
      height: 150,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _apiPackages.length,
              onPageChanged: (index) => setState(() => _carouselIndex = index),
              itemBuilder: (context, index) {
                final item = _apiPackages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 6.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.beige,
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: NetworkImage(item['img']!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          AppColor.beige.withOpacity(0.15),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        item['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          _buildDots(),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_apiPackages.length, (i) {
        final isActive = i == _carouselIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColor.primary
                : AppColor.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColor.blueFont,
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text('View All', style: TextStyle(color: AppColor.primary)),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColor.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final item = categories[idx];
          return Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.network(
                    item['img']!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(item['label']!, style: TextStyle(color: AppColor.blueFont)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServiceProviders() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _apiServiceCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, idx) {
          final item = _apiServiceCategories[idx];
          final String title = item['name'] ?? 'Service';
          final String imageUrl = item['img'] ?? 'assets/App_photos/img.png';
          return GestureDetector(
            // <--- ADD THIS WRAPPER
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProvidersListView(
                    categoryTitle:
                        title, // Passes "Photographers", "Venues", etc.
                  ),
                ),
              );
            },
            child: Container(
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.primary.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      imageUrl,
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColor.blueFont,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchBar(),
          //_buildTabs(),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _buildCarousel(),
          ),
          _buildSectionHeader(
            'Events Categories',
            onViewAll: () => debugPrint('view all categories'),
          ),
          _buildCategories(),
          _buildSectionHeader(
            'Service Providers',
            onViewAll: () => debugPrint('view all providers'),
          ),
          _buildServiceProviders(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedBottomIndex,
      onTap: (idx) {
        setState(() => _selectedBottomIndex = idx);

        if (idx == 4) {
          // profile icon
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserProfilePage()),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHomeAppBar(),

      /*appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _buildAppBar(),
      ),*/
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),

      floatingActionButton: FloatingActionButton(
        tooltip: "Create Event", // <-- hover message
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventView()),
          );
        },
        backgroundColor: AppColor.primary,
        hoverColor:
            AppColor.secondaryBlue, // <-- color change on hover (web/desktop)
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
