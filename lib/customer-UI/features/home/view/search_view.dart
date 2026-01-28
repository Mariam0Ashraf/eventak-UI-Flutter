import 'dart:async';
import 'package:eventak/customer-UI/features/home/data/home_service.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/data/search_service.dart';
import 'package:eventak/customer-UI/features/home/data/search_result_model.dart';
import 'package:eventak/customer-UI/features/home/widgets/search_result_tile.dart';
import 'package:eventak/customer-UI/features/services/service_details/view/service_details_view.dart';
import 'package:eventak/customer-UI/features/packages/package_details/view/package_details_view.dart';
import 'package:eventak/customer-UI/features/home/data/areas_service.dart';
import 'package:eventak/customer-UI/features/home/view/area_view.dart';

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
  final AreasService _areasService = AreasService();

  // Areas tree
  List<AreaNode> _areasTree = [];
  AreaNode? _selectedCountry;
  AreaNode? _selectedGov;
  AreaNode? _selectedCity;
  int? _selectedAreaId;

  // Results & categories
  List<SearchResult> _results = [];
  List<Map<String, dynamic>> _availableCategories = [];

  // Filters
  bool _isLoading = false;
  bool _loadingMore = false;

  String _query = '';
  String? _type; // UI only (service/package/null)
  String? _category; // category id as string
  double? _minPrice;
  double? _maxPrice;
  bool? _popular;

  // Pagination
  int _servicesPage = 1;
  int _packagesPage = 1;
  int _servicesLastPage = 1;
  int _packagesLastPage = 1;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAreas();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_loadingMore) {
        _loadMore();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchCategories() async {
    try {
      final results = await _homeService.getServiceCategories();
      if (mounted) setState(() => _availableCategories = results);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> _fetchAreas() async {
    try {
      final tree = await _areasService.getAreasTree();
      if (mounted) setState(() => _areasTree = tree);
    } catch (e) {
      debugPrint("Error fetching areas: $e");
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

      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    final hasAnyFilter =
        _type != null ||
        _category != null ||
        _selectedAreaId != null ||
        _minPrice != null ||
        _maxPrice != null ||
        (_popular == true);

    if (_query.isEmpty && !hasAnyFilter) return;

    setState(() => _isLoading = true);

    try {
      final data = await _searchService.search(
        query: _query,
        areaId: _selectedAreaId,
        categoryId: _category,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        filter: (_popular == true) ? 'popular' : null,
        servicesPage: _servicesPage,
        packagesPage: _packagesPage,
      );

      setState(() {
        final List<SearchResult> combined = [];

        if (_type == null || _type == 'service') {
          combined.addAll((data['services'] as List<SearchResult>?) ?? []);
        }
        if (_type == null || _type == 'package') {
          combined.addAll((data['packages'] as List<SearchResult>?) ?? []);
        }

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

    if ((_type == null || _type == 'service') &&
        _servicesPage < _servicesLastPage) {
      _servicesPage++;
      _loadingMore = true;
      _performSearch();
    } else if ((_type == null || _type == 'package') &&
        _packagesPage < _packagesLastPage) {
      _packagesPage++;
      _loadingMore = true;
      _performSearch();
    }
  }

  void _handleResultTap(SearchResult item) {
    if (item.type == SearchResultType.service) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceDetailsView(serviceId: item.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PackageDetailsView(packageId: item.id),
        ),
      );
    }
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) {
        String? selectedType = _type;
        String? selectedCategoryId = _category;
        double? minP = _minPrice;
        double? maxP = _maxPrice;
        bool isPop = _popular ?? false;

        AreaNode? selectedCountry = _selectedCountry;
        AreaNode? selectedGov = _selectedGov;
        AreaNode? selectedCity = _selectedCity;
        int? selectedAreaId = _selectedAreaId;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Filters'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String?>(
                      isExpanded: true,
                      value: selectedType,
                      items: const [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All'),
                        ),
                        DropdownMenuItem<String?>(
                          value: 'service',
                          child: Text('Service'),
                        ),
                        DropdownMenuItem<String?>(
                          value: 'package',
                          child: Text('Package'),
                        ),
                      ],
                      onChanged: (v) => setDialogState(() => selectedType = v),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Service Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                                      selectedCategoryId = (val == true)
                                          ? id
                                          : null;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Area',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<AreaNode>(
                      value: selectedCountry,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Country',
                      ),
                      items: _areasTree
                          .map(
                            (a) =>
                                DropdownMenuItem(value: a, child: Text(a.name)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setDialogState(() {
                          selectedCountry = v;
                          selectedGov = null;
                          selectedCity = null;
                          selectedAreaId = v?.id;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<AreaNode>(
                      value: selectedGov,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Governorate',
                      ),
                      items: (selectedCountry?.children ?? [])
                          .map(
                            (g) =>
                                DropdownMenuItem(value: g, child: Text(g.name)),
                          )
                          .toList(),
                      onChanged: (selectedCountry == null)
                          ? null
                          : (v) {
                              setDialogState(() {
                                selectedGov = v;
                                selectedCity = null;
                                selectedAreaId = v?.id;
                              });
                            },
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<AreaNode>(
                      value: selectedCity,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'City',
                      ),
                      items: (selectedGov?.children ?? [])
                          .map(
                            (c) =>
                                DropdownMenuItem(value: c, child: Text(c.name)),
                          )
                          .toList(),
                      onChanged: (selectedGov == null)
                          ? null
                          : (v) {
                              setDialogState(() {
                                selectedCity = v;
                                selectedAreaId = v?.id;
                              });
                            },
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Price Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                      onChanged: (v) =>
                          setDialogState(() => isPop = v ?? false),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                ),
                onPressed: () {
                  setState(() {
                    _type = selectedType;
                    _category = selectedCategoryId;

                    _selectedCountry = selectedCountry;
                    _selectedGov = selectedGov;
                    _selectedCity = selectedCity;
                    _selectedAreaId = selectedAreaId;

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
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
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
                child: Icon(Icons.tune, color: AppColor.lightGrey),
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
                        separatorBuilder: (_, __) =>
                            Divider(color: Colors.grey.shade300),
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
