import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/shared/app_bar_widget.dart';

// --- Widget Imports ---
import 'package:eventak/service-provider-UI/features/home/widgets/home_header.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/statistics_section.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/packages_section.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/offers_section.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/portfolio_section.dart';

// --- Data Import ---
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';

// --- New Feature Import ---
import 'package:eventak/service-provider-UI/features/add_service/view/add_service_view.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/view/add_package_view.dart';

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
      final results = await Future.wait([
        _dashboardService.getUserProfile(),
        _dashboardService.getMyServices(),
        _dashboardService.getPackages(),
      ]);

      final userData = results[0] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _providerName = userData['name'] ?? '';
          _services = results[1] as List<String>;
          _packages = results[2] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHomeAppBar(),

      // --- Updated Floating Action Button ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigate to the new Add Service View
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceView()),
          );

          // If the user successfully added a service (result == true),
          // refresh the dashboard data to show the new service.
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
            HomeHeader(services: _services, providerName: _providerName),
            const SizedBox(height: 20),
            const StatisticsSection(),
            const SizedBox(height: 24),
            PackagesSection(
              packages: _packages,
              onDelete: _handleDeletePackage,
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPackageView()),
                );

                if (created == true) {
                  _loadDashboardData(); // refresh
                }
              },
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
