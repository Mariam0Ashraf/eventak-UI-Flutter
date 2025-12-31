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

// --- Data Imports ---
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
  State<ServiceProviderHomeView> createState() => _ServiceProviderHomeViewState();
}

class _ServiceProviderHomeViewState extends State<ServiceProviderHomeView> {
  final DashboardService _dashboardService = DashboardService();
  final ScrollController _mainScrollController = ScrollController();

  List<Map<String, dynamic>> _myServices = [];
  List<Map<String, dynamic>> _packages = [];
  String _providerName = '';
  
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMorePackages = true; 
  int _currentServicePage = 1;
  int _currentPackagePage = 1;

  int? _selectedServiceId; 

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    
    _mainScrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_mainScrollController.position.pixels >= _mainScrollController.position.maxScrollExtent * 0.8) {
      if (!_isFetchingMore && _hasMorePackages) {
        _loadMorePackages();
      }
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasMorePackages = true;
        _currentServicePage = 1;
        _currentPackagePage = 1;
      });

      final results = await Future.wait([
        _dashboardService.getUserProfile(),
        _dashboardService.getMyServices(page: _currentServicePage),
        _dashboardService.getPackages(page: _currentPackagePage),
      ]);

      final userData = results[0] as Map<String, dynamic>;
      final services = List<Map<String, dynamic>>.from(results[1] as List);
      final fetchedPackages = List<Map<String, dynamic>>.from(results[2] as List);

      if (mounted) {
        setState(() {
          _providerName = userData['name'] ?? 'Provider';
          _myServices = services;
          _packages = fetchedPackages; 
          _isLoading = false;
          
          if (fetchedPackages.length < 15) {
            _hasMorePackages = false;
          }
        });
      }
    } catch (e) {
      debugPrint(" Dashboard Load Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePackages() async {
    if (_isFetchingMore || !_hasMorePackages) return;
    
    setState(() => _isFetchingMore = true);
    try {
      _currentPackagePage++;
      final morePackages = await _dashboardService.getPackages(page: _currentPackagePage);
      
      if (mounted) {
        if (morePackages.isEmpty) {
          _hasMorePackages = false;
        } else {
          setState(() {
            _packages.addAll(morePackages); 
            if (morePackages.length < 15) _hasMorePackages = false;
          });
        }
      }
    } catch (e) {
      debugPrint("🔴 Load More Error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }

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
        controller: _mainScrollController, 
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
            const StatisticsSection(), 
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
                final serviceModel = MyService.fromJson(serviceMap);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowServicePage(service: serviceModel),
                  ),
                ).then((_) => _loadDashboardData());
              },
            ),

            const SizedBox(height: 24),

            PackagesSection(
              packages: _packages,
             
              onRefresh: _loadDashboardData,
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

            if (_isFetchingMore) 
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),

            const SizedBox(height: 24),
            const OffersSection(offers: []),
            const SizedBox(height: 24),
            const PortfolioSection(portfolio: []),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}