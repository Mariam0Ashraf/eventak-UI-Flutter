import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/shared/app_bar_widget.dart';

// --- Widget Imports ---
import 'package:eventak/service-provider-UI/features/home/widgets/home_header.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/statistics_section.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/packages_section.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/offers_section.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/portfolio_section.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/service_tabs.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/my_services_section.dart';



// --- Data Import ---
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';

// --- Feature Imports ---
import 'package:eventak/service-provider-UI/features/add_service/view/add_service_view.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/view/add_package_view.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/my_services_list_view.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/show_service_view.dart';


class ServiceProviderHomeView extends StatefulWidget {
  const ServiceProviderHomeView({super.key});

  @override
  State<ServiceProviderHomeView> createState() =>
      _ServiceProviderHomeViewState();
}

class _ServiceProviderHomeViewState extends State<ServiceProviderHomeView> {
  final DashboardService _dashboardService = DashboardService();

  List<Map<String, dynamic>> _myServices = [];

  final int _selectedTabIndex = 0;
  int? _selectedServiceId; // null = All Services

  List<String> _serviceNames = [];

  List<Map<String, dynamic>> _packages = [];
  String _providerName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
  try {
    print("DEBUG: Starting API calls...");
    
    final results = await Future.wait([
      _dashboardService.getUserProfile(),
      _dashboardService.getMyServices(),
      _dashboardService.getPackages(),
    ]);

    print("DEBUG: API calls finished successfully!");

    // Use 'dynamic' here to prevent the crash
    final dynamic rawServicesData = results[1];
    print("DEBUG: RAW DATA IS: $rawServicesData");
    print("DEBUG: DATA TYPE IS: ${rawServicesData.runtimeType}");

    final userData = results[0] as Map<String, dynamic>;
    
    // SAFE PARSING:
    List<Map<String, dynamic>> services = [];
    if (rawServicesData is List) {
      services = List<Map<String, dynamic>>.from(rawServicesData);
    } else if (rawServicesData is Map && rawServicesData['data'] != null) {
      // Many backends wrap the list in a 'data' key
      services = List<Map<String, dynamic>>.from(rawServicesData['data']);
    }

    if (mounted) {
      setState(() {
        _providerName = userData['name'] ?? '';
        _myServices = services;
        _serviceNames = services.map((s) => s['name'].toString()).toList();
        
        // Fix for packages
        final allPackages = results[2] as List;
        _packages = allPackages
            .map((p) => Map<String, dynamic>.from(p))
            .where((p) => p['provider_id'] == userData['id'])
            .toList();

        _isLoading = false;
      });
    }
  } catch (e, stack) {
    print("DEBUG: CRASH DETECTED!");
    print("ERROR: $e");
    print("STACKTRACE: $stack");
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  void _handleDeletePackage(int id) async {
    try {
      await _dashboardService.deletePackage(id);
      _loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  //filterd packages //will not be applied since it is not make sence
  /*List<Map<String, dynamic>> get _filteredPackages {
  // All Services
  if (_selectedServiceId == null) {
    return _packages;
  }

  // Filter by selected service
  return _packages.where((package) {
    return package['service_id'] == _selectedServiceId;
  }).toList();
}*/

  //filterd offers
  /*List<Map<String, dynamic>> get _filteredOffers {
  if (_selectedServiceId == null) {
    return _offers;
  }

  return _offers.where((offer) {
    return offer['service_id'] == _selectedServiceId;
  }).toList();
}*/

  //filterd portofolio
  /*List<Map<String, dynamic>> get _filteredPortfolio {
  if (_selectedServiceId == null) {
    return _portfolio;
  }

  return _portfolio.where((item) {
    return item['service_id'] == _selectedServiceId;
  }).toList();
}
*/

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHomeAppBar(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceView()),
          );

          if (result == true) {
            _loadDashboardData();
          }
        },
        label: const Text('Add New Service'),
        icon: const Icon(Icons.add_business_outlined),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(providerName: _providerName),

            const SizedBox(height: 12),
            ServiceTabs(
              services: _myServices,
              selectedServiceId: _selectedServiceId,
              onServiceSelected: (id) {
                setState(() {
                  _selectedServiceId = id;
                });
              },
            ),

            const SizedBox(height: 20),
            const StatisticsSection(), //waiting for endpoints
            const SizedBox(height: 24),

            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Services',
                  style: TextStyle(
                    color: AppColor.blueFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyServicesListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.grid_view_outlined, size: 18),
                  label: const Text('My Services'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColor.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),*/

            const SizedBox(height: 24),

            
            ServicesSection(
              services: _myServices,
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyServicesListPage()),
                );
              },
              onServiceTap: (Map<String, dynamic> serviceMap) {
              // 1. Convert the Map to the MyService object using your fromJson
              final serviceModel = MyService.fromJson(serviceMap);

              // 2. Navigate to the ShowServicePage
              Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => ShowServicePage(service: serviceModel),
                ),
              ).then((_) {
              // 3. Refresh data when returning from the detail page 
              // (in case the service was deleted or edited)
                _loadDashboardData();
              });
            },
            ),

            const SizedBox(height: 24),

            /// PACKAGES
            PackagesSection(
              packages: _packages,
              //packages: _filterPackages, //if i applied the filters
              onDelete: _handleDeletePackage,
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPackageView(services: _myServices),
                  ),
                );

                if (created == true) {
                  _loadDashboardData();
                }
              },
            ),

            const SizedBox(height: 24),
            const OffersSection(offers: []),
            //OffersSection(offers: _filteredOffers), //if filterd offers applied
            const SizedBox(height: 24),
            const PortfolioSection(portfolio: []),
            //PortfolioSection(portfolio: _filteredPortfolio), //if filterd portofolio applied
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
