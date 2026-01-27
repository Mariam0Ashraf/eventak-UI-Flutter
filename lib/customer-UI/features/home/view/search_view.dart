import 'dart:async';
import 'package:eventak/customer-UI/features/home/data/home_service.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/data/search_service.dart';
import 'package:eventak/customer-UI/features/home/data/search_result_model.dart';
import 'package:eventak/customer-UI/features/home/widgets/search_result_tile.dart';
import 'package:eventak/customer-UI/features/services/service_details/view/service_details_view.dart';
import 'package:eventak/customer-UI/features/packages/package_details/view/package_details_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  final HomeService _homeService = HomeService(); 
  final ScrollController _scrollController = ScrollController();

  List<SearchResult> _results = [];
  List<Map<String, dynamic>> _availableCategories = []; 
  
  bool _isLoading = false;
  bool _loadingMore = false;
  String _query = '';
  String? _type; //service/package
  String? _category; 
  String? _location;
  double? _minPrice;
  double? _maxPrice;
  bool? _popular;

  int _servicesPage = 1;
  int _packagesPage = 1;
  int _servicesLastPage = 1;
  int _packagesLastPage = 1;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories on initialization
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_loadingMore) {
        _loadMore();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  // Fetch real categories from your HomeService
  Future<void> _fetchCategories() async {
    try {
      final results = await _homeService.getServiceCategories();
      if (mounted) {
        setState(() => _availableCategories = results);
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _query = query;
        _servicesPage = 1;
        _packagesPage = 1;
        _results.clear();
      });
      if (query.isNotEmpty) _performSearch();
    });
  }

  Future<void> _performSearch() async {
    if (_query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final data = await _searchService.search(
        query: _query,
        category: _category,
        location: _location,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        popular: _popular,
        type: _type,
        servicesPage: _servicesPage,
        packagesPage: _packagesPage,
      );

      setState(() {
        final List<SearchResult> combined = [];
        if (_type == null || _type == 'service') combined.addAll(data['services']);
        if (_type == null || _type == 'package') combined.addAll(data['packages']);

        _results.addAll(combined);
        _servicesLastPage = data['servicesMeta']?['last_page'] ?? 1;
        _packagesLastPage = data['packagesMeta']?['last_page'] ?? 1;

        _isLoading = false;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Search Error: $e");
    }
  }

  void _loadMore() {
    if (_loadingMore) return;
    if ((_type == null || _type == 'service') && _servicesPage < _servicesLastPage) {
      _servicesPage++;
      _loadingMore = true;
      _performSearch();
    } else if ((_type == null || _type == 'package') && _packagesPage < _packagesLastPage) {
      _packagesPage++;
      _loadingMore = true;
      _performSearch();
    }
  }

  void _handleResultTap(SearchResult item) {
    if (item.type == SearchResultType.service) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailsView(serviceId: item.id)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PackageDetailsView(packageId: item.id)));
    }
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) {
        // Local temporary variables to hold dialog state
        String? selectedType = _type;
        String? selectedCategoryId = _category;
        String? selectedLoc = _location;
        double? minP = _minPrice;
        double? maxP = _maxPrice;
        bool isPop = _popular ?? false;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Filters'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 'service', child: Text('Service')),
                        DropdownMenuItem(value: 'package', child: Text('Package')),
                      ],
                      onChanged: (v) => setDialogState(() => selectedType = v),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text('Service Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _availableCategories.isEmpty 
                        ? const Center(child: Text("No categories found"))
                        : ListView.builder(
                            itemCount: _availableCategories.length,
                            itemBuilder: (ctx, index) {
                              final cat = _availableCategories[index];
                              final id = cat['id'].toString();
                              final name = cat['name'] ?? 'Unknown';
                              return CheckboxListTile(
                                title: Text(name),
                                dense: true,
                                value: selectedCategoryId == id,
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedCategoryId = (val == true) ? id : null;
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            },
                          ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      decoration: const InputDecoration(hintText: 'e.g. Cairo'),
                      onChanged: (v) => selectedLoc = v,
                      controller: TextEditingController(text: selectedLoc),
                    ),
                    const SizedBox(height: 16),

                    const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Min'),
                            onChanged: (v) => minP = double.tryParse(v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'Max'),
                            onChanged: (v) => maxP = double.tryParse(v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Popular only'),
                      value: isPop,
                      onChanged: (v) => setDialogState(() => isPop = v ?? false),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                onPressed: () {
                  setState(() {
                    _type = selectedType;
                    _category = selectedCategoryId;
                    _location = selectedLoc;
                    _minPrice = minP;
                    _maxPrice = maxP;
                    _popular = isPop;
                    _results.clear();
                    _servicesPage = 1;
                    _packagesPage = 1;
                  });
                  Navigator.pop(context);
                  _performSearch();
                },
                child: const Text('Apply', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: AppColor.background,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: AppColor.blueFont),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _openFilterDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                
                child: Icon(Icons.tune, color: AppColor.lightGrey,),
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              Expanded(
                child: _results.isEmpty && !_isLoading
                    ? const Center(child: Text("Type to search"))
                    : ListView.separated(
                        controller: _scrollController,
                        itemCount: _results.length + (_loadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => Divider(color: Colors.grey.shade300),
                        itemBuilder: (context, index) {
                          if (_loadingMore && index == _results.length) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final item = _results[index];
                          return SearchResultTile(
                            item: item,
                            onTap: () => _handleResultTap(item),
                          );

                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}