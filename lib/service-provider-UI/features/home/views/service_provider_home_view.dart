// lib/views/service_provider_home_view.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
// Import data
import 'package:eventak/service-provider-UI/features/home/data/dummy_data.dart';
// Import widgets
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/service-provider-UI/widgets/home_header.dart';
import 'package:eventak/service-provider-UI/widgets/statistics_section.dart';
import 'package:eventak/service-provider-UI/widgets/packages_section.dart';
import 'package:eventak/service-provider-UI/widgets/offers_section.dart';
import 'package:eventak/service-provider-UI/widgets/portfolio_section.dart';

class ServiceProviderHomeView extends StatelessWidget {
  const ServiceProviderHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Data is accessed directly from the dummy_data file for simplicity
    // In a real app, this data would come from a State Management solution (BLoC, Provider, etc.)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHomeAppBar(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => debugPrint('Navigate to Add New Service'),
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
            // 1. Header (Stateful Widget)
            HomeHeader(services: mockServices),
            const SizedBox(height: 20),

            // 2. Statistics (Stateless Widget)
            const StatisticsSection(),
            const SizedBox(height: 24),

            // 3. Packages (Stateless Widget)
            PackagesSection(packages: mockPackages),
            const SizedBox(height: 24),

            // 4. Offers (Stateless Widget)
            OffersSection(offers: mockOffers),
            const SizedBox(height: 24),

            // 5. Portfolio (Stateless Widget)
            PortfolioSection(portfolio: mockPortfolio),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
