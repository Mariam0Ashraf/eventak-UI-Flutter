import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/custom_nav_bar.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/customer-UI/features/services/data/provider_model.dart';
import 'package:eventak/customer-UI/features/services/widgets/provider_card.dart';
import 'package:flutter/material.dart';

class ProvidersListView extends StatefulWidget {
  final String categoryTitle;

  const ProvidersListView({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<ProvidersListView> createState() => _ProvidersListViewState();
}

class _ProvidersListViewState extends State<ProvidersListView> {
  late List<ServiceProvider> providers;
  
  int _selectedBottomIndex = 1; 

  @override
  void initState() {
    super.initState();
    providers = ServiceProvider.getDummyData(widget.categoryTitle);
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedBottomIndex = index);

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UserProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F0E4), 
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: ListView.builder(
        itemCount: providers.length,
        itemBuilder: (context, index) {
          return ProviderCard(provider: providers[index]);
        },
      ),

      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedBottomIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}