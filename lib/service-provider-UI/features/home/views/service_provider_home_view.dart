// lib/views/service_provider_home_view.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/data/dummy_data.dart'; 
import 'package:eventak/shared/app_bar_widget.dart';


class ServiceProviderHomeView extends StatefulWidget {
  const ServiceProviderHomeView({super.key});

  @override
  State<ServiceProviderHomeView> createState() => _ServiceProviderHomeViewState();
}

class _ServiceProviderHomeViewState extends State<ServiceProviderHomeView> {
  String? _selectedService;
  final bool _hasPackages = mockPackages.isNotEmpty;
  final bool _hasOffers = mockOffers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedService = mockServices.isNotEmpty ? mockServices.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHomeAppBar(), // <-- Using the extracted AppBar widget
      
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
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatisticsSection(),
            const SizedBox(height: 24),
            _buildPackagesSection(), 
            const SizedBox(height: 24),
            _buildOffersSection(), 
            const SizedBox(height: 24),
            _buildPortfolioSection(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // --- Header Widgets ---

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage('assets/App_photos/img.png'),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'welcome Back👋',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Text(
              'Ahmed Photography',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _buildServiceDropdown(), 
          ],
        ),
      ],
    );
  }

  Widget _buildServiceDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)), 
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedService,
          icon: Icon(Icons.arrow_drop_down, color: AppColor.blueFont),
          style: const TextStyle(
              fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
          dropdownColor: Colors.white,
          items: mockServices.map((String service) {
            return DropdownMenuItem<String>(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedService = newValue;
            });
            debugPrint('Service selected: $newValue');
          },
        ),
      ),
    );
  }

  // --- Statistics Section ---

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Statistics', includeButton: false),
        const SizedBox(height: 10),
        Row(
          children: [
            _statCard('Upcoming Bookings', '3', Icons.event, () => debugPrint('Upcoming Tapped')),
            _statCard('New Requests', '2', Icons.inbox, () => debugPrint('Requests Tapped')),
            _statCard('Reviews', '4.8', Icons.star, () => debugPrint('Reviews Tapped')),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.beige.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColor.blueFont),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColor.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Packages Section ---

  Widget _buildPackagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'My Packages',
          buttonText: 'Create Package',
          onPressed: () => debugPrint('Navigate to Create Package'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90, // Reduced height since image is removed
          child: !_hasPackages
              ? _buildEmptyState('You did not create packages yet.', Icons.widgets_outlined)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockPackages.length,
                  itemBuilder: (context, index) {
                    final package = mockPackages[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _packageCard(package),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  // Package Card (UPDATED: Photo Removed)
  Widget _packageCard(Map<String, String> package) {
    return Container(
      width: 250, 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.blueFont.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          // REMOVED: Image.asset section is gone
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  package['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  package['details']!,
                  style:  TextStyle(color: AppColor.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(icon:  Icon(Icons.edit, size: 20, color: AppColor.grey), onPressed: () {}),
        ],
      ),
    );
  }

  // --- Offers Section ---
  
  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'My Offers',
          buttonText: 'Add Offer',
          onPressed: () => debugPrint('Navigate to Add Offer'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100, // Adjusted height for actions
          child: !_hasOffers
              ? _buildEmptyState('You do not have any active offers.', Icons.discount_outlined)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mockOffers.length,
                  itemBuilder: (context, index) {
                    final offer = mockOffers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _offerCard(offer),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  // Offer Card (Includes Edit/Delete)
  Widget _offerCard(Map<String, String> offer) {
    return Container(
      width: 200, 
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.blueFont.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.discount, color: AppColor.blueFont, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  offer['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            offer['details']!,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(), 
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: AppColor.blueFont,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => debugPrint('Edit Offer: ${offer['title']}'),
                tooltip: 'Edit Offer',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => debugPrint('Delete Offer: ${offer['title']}'),
                tooltip: 'Delete Offer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Portfolio Section ---

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'My Portfolio',
          buttonText: 'Add Item',
          onPressed: () => debugPrint('Navigate to Add Portfolio Item'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mockPortfolio.length,
            itemBuilder: (context, index) {
              final item = mockPortfolio[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _portfolioItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _portfolioItem(Map<String, String> item) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              item['image']!,
              width: 120,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              item['desc']!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  // --- Reusable Utility Widgets ---

  Widget _sectionTitle(String title, {bool includeButton = true}) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle(title),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add, size: 18),
          label: Text(buttonText),
          style: TextButton.styleFrom(
            foregroundColor: AppColor.blueFont,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.grey.shade400), 
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}