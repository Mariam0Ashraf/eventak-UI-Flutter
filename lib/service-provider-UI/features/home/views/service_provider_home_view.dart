import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/service-provider-UI/widgets/home_header.dart';
import 'package:eventak/service-provider-UI/widgets/statistics_section.dart';
import 'package:eventak/service-provider-UI/widgets/packages_section.dart';
import 'package:eventak/service-provider-UI/widgets/offers_section.dart';
import 'package:eventak/service-provider-UI/widgets/portfolio_section.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';

class ServiceProviderHomeView extends StatefulWidget {
  const ServiceProviderHomeView({super.key});

  @override
  State<ServiceProviderHomeView> createState() =>
      _ServiceProviderHomeViewState();
}

class _ServiceProviderHomeViewState extends State<ServiceProviderHomeView> {
  final DashboardService _dashboardService = DashboardService();

  List<String> _services = [];
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
      //debugPrint('Dashboard: Starting data fetch...');

      final results = await Future.wait([
        _dashboardService.getUserProfile(),
        _dashboardService.getMyServices(),
        _dashboardService.getPackages(),
      ]);

      final userData = results[0] as Map<String, dynamic>;

      setState(() {
        _providerName = userData['name'] ?? '';
        _services = results[1] as List<String>;
        _packages = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleDeletePackage(int id) async {
    try {
      await _dashboardService.deletePackage(id);
      _loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
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
        onPressed: () {},
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
            HomeHeader(services: _services, providerName: _providerName),
            const SizedBox(height: 20),
            const StatisticsSection(),
            const SizedBox(height: 24),
            PackagesSection(
              packages: _packages,
              onDelete: _handleDeletePackage,
            ),
            const SizedBox(height: 24),
            const OffersSection(offers: []),
            const SizedBox(height: 24),
            const PortfolioSection(portfolio: []),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
