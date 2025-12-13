import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/custom_nav_bar.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/customer-UI/features/services/data/provider_model.dart';
import 'package:eventak/customer-UI/features/services/data/providers_service.dart'; // Import Service
import 'package:eventak/customer-UI/features/services/widgets/provider_card.dart';
import 'package:flutter/material.dart';

class ProvidersListView extends StatefulWidget {
  final String categoryTitle;
  final int categoryId;

  const ProvidersListView({
    super.key,
    required this.categoryTitle,
    required this.categoryId, 
  });

  @override
  State<ProvidersListView> createState() => _ProvidersListViewState();
}

class _ProvidersListViewState extends State<ProvidersListView> {
  final ProvidersService _service = ProvidersService();
  List<ServiceProvider> _allProviders = [];
  List<ServiceProvider> _filteredProviders = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  int _selectedBottomIndex = 1; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.fetchServices();
      setState(() {
        _allProviders = data;
        _filteredProviders = _allProviders
            .where((p) => p.categoryId == widget.categoryId)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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

      body: _buildBody(),

      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedBottomIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            TextButton(onPressed: _loadData, child: const Text("Retry"))
          ],
        ),
      );
    }

    if (_filteredProviders.isEmpty) {
      return Center(
        child: Text(
          "No providers found for ${widget.categoryTitle}",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredProviders.length,
      itemBuilder: (context, index) {
        return ProviderCard(provider: _filteredProviders[index]);
      },
    );
  }
}