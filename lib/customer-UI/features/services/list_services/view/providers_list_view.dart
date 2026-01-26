import 'package:eventak/core/constants/custom_nav_bar.dart';
import 'package:eventak/auth/view/profile_view.dart';
import 'package:eventak/customer-UI/features/services/list_services/data/provider_model.dart';
import 'package:eventak/customer-UI/features/services/list_services/data/providers_service.dart'; 
import 'package:eventak/customer-UI/features/services/list_services/widgets/provider_card.dart';
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
  final ProvidersService _service = ProvidersService();
  final ScrollController _scrollController = ScrollController();

  List<ServiceProvider> _filteredProviders = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _errorMessage;
  
  int _selectedBottomIndex = 1; 

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMoreData && _errorMessage == null) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      // Fetch from service
      final data = await _service.fetchServices(page: _currentPage);
      
      if (mounted) {
        setState(() {
          if (widget.categoryTitle == "All") {
            _filteredProviders = data; 
          } else {
            _filteredProviders = data.where(
              (p) => p.categories.contains(widget.categoryTitle),
            ).toList();
          }

          _isLoading = false;
          
          // If the returned data is less than our page size (15), no more data exists
          if (data.length < 15) {
            _hasMoreData = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreData() async {
    // Prevent multiple simultaneous fetches
    setState(() => _isFetchingMore = true);
    
    try {
      final nextPage = _currentPage + 1;
      final newData = await _service.fetchServices(page: nextPage);
      
      if (mounted) {
        setState(() {
          if (newData.isEmpty) {
            _hasMoreData = false;
          } else {
            if (widget.categoryTitle == "All") {
              _filteredProviders.addAll(newData);
            } else {
              final filteredNew = newData.where(
                (p) => p.categories.contains(widget.categoryTitle),
              ).toList();
              _filteredProviders.addAll(filteredNew);
            }

            _currentPage = nextPage;

            // Check if we've reached the end based on response length
            if (newData.length < 15) {
              _hasMoreData = false;
            }
          }
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      debugPrint("Load More Error: $e");
      if (mounted) {
        setState(() => _isFetchingMore = false);
      }
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedBottomIndex = index);
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 4) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserProfilePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedBottomIndex,
        onTap: _onNavBarTap,
      ),
    );
  }


  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            Text('Error: $_errorMessage'),
            TextButton(onPressed: _loadInitialData, child: const Text("Retry"))
          ],
        ),
      );
    }

    if (_filteredProviders.isEmpty) {
      return Center(child: Text("No providers found for ${widget.categoryTitle}"));
    }

    return ListView.builder(
      controller: _scrollController, 
      itemCount: _filteredProviders.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredProviders.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return ProviderCard(provider: _filteredProviders[index]);
      },
    );
  }
}