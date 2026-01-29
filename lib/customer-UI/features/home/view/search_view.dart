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
  String? _type; // UI only: service/package/null
  String? _category; // category id as string
  double? _minPrice;
  double? _maxPrice;
  bool _popular = false;

  
  bool? _includeServices;
  bool? _includePackages;

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
        (_popular == true) ||
        (_includeServices != null) ||
        (_includePackages != null);

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

        
        includeServices: _includeServices,
        includePackages: _includePackages,

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

  
  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _FilterSheet(
          availableCategories: _availableCategories,
          areasTree: _areasTree,

          type: _type,
          categoryId: _category,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          popular: _popular,

          includeServices: _includeServices,
          includePackages: _includePackages,

          selectedCountry: _selectedCountry,
          selectedGov: _selectedGov,
          selectedCity: _selectedCity,
          selectedAreaId: _selectedAreaId,
        );
      },
    );

    if (result == null) return;

    setState(() {
      _type = result.type;
      _category = result.categoryId;
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _popular = result.popular;

      _includeServices = result.includeServices;
      _includePackages = result.includePackages;

      _selectedCountry = result.selectedCountry;
      _selectedGov = result.selectedGov;
      _selectedCity = result.selectedCity;
      _selectedAreaId = result.selectedAreaId;

      _results.clear();
      _servicesPage = 1;
      _packagesPage = 1;
    });

    _performSearch();
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
              onTap: _openFilterSheet,
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

// ====================== FILTER SHEET ======================

class _FilterSheet extends StatefulWidget {
  final List<Map<String, dynamic>> availableCategories;
  final List<AreaNode> areasTree;

  final String? type;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool popular;

  
  final bool? includeServices;
  final bool? includePackages;

  final AreaNode? selectedCountry;
  final AreaNode? selectedGov;
  final AreaNode? selectedCity;
  final int? selectedAreaId;

  const _FilterSheet({
    required this.availableCategories,
    required this.areasTree,
    required this.type,
    required this.categoryId,
    required this.minPrice,
    required this.maxPrice,
    required this.popular,
    required this.includeServices,
    required this.includePackages,
    required this.selectedCountry,
    required this.selectedGov,
    required this.selectedCity,
    required this.selectedAreaId,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _type;
  late String? _categoryId;
  late bool _popular;

  
  late bool _incServicesUI;
  late bool _incPackagesUI;

  AreaNode? _country;
  AreaNode? _gov;
  AreaNode? _city;
  int? _areaId;

  late TextEditingController _minController;
  late TextEditingController _maxController;

  double? _minPrice;
  double? _maxPrice;

  @override
  void initState() {
    super.initState();

    _type = widget.type;
    _categoryId = widget.categoryId;
    _popular = widget.popular;

    
    _incServicesUI = widget.includeServices != false;
    _incPackagesUI = widget.includePackages != false;

    _country = widget.selectedCountry;
    _gov = widget.selectedGov;
    _city = widget.selectedCity;
    _areaId = widget.selectedAreaId;

    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;

    _minController = TextEditingController(
      text: _minPrice == null ? '' : _minPrice!.toString(),
    );
    _maxController = TextEditingController(
      text: _maxPrice == null ? '' : _maxPrice!.toString(),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _type = null;
      _categoryId = null;
      _popular = false;

      _incServicesUI = true;
      _incPackagesUI = true;

      _country = null;
      _gov = null;
      _city = null;
      _areaId = null;

      _minPrice = null;
      _maxPrice = null;
      _minController.text = '';
      _maxController.text = '';
    });
  }

  void _apply() {
    
    if (!_incServicesUI && !_incPackagesUI) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable Services or Packages (at least one).'),
        ),
      );
      return;
    }

    
    bool? includeServicesParam;
    bool? includePackagesParam;

    if (_incServicesUI && _incPackagesUI) {
      includeServicesParam = null;
      includePackagesParam = null;
    } else {
      if (!_incServicesUI) includeServicesParam = false;
      if (!_incPackagesUI) includePackagesParam = false;
    }

    Navigator.pop(
      context,
      _FilterResult(
        type: _type,
        categoryId: _categoryId,
        popular: _popular,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        includeServices: includeServicesParam,
        includePackages: includePackagesParam,
        selectedCountry: _country,
        selectedGov: _gov,
        selectedCity: _city,
        selectedAreaId: _areaId,
      ),
    );
  }

  void _selectType(String? v) {
    setState(() {
      _type = v;

     
      if (v == 'service') {
        _incServicesUI = true;
        _incPackagesUI = false;
      } else if (v == 'package') {
        _incServicesUI = false;
        _incPackagesUI = true;
      } else {
        _incServicesUI = true;
        _incPackagesUI = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Handle
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _reset,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.primary, 
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Content scroll
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    children: [
                      _sectionTitle('Type'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(
                            label: 'All',
                            active: _type == null,
                            onTap: () => _selectType(null),
                          ),
                          _chip(
                            label: 'Service',
                            active: _type == 'service',
                            onTap: () => _selectType('service'),
                          ),
                          _chip(
                            label: 'Package',
                            active: _type == 'package',
                            onTap: () => _selectType('package'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      _sectionTitle('Service Category'),
                      if (widget.availableCategories.isEmpty)
                        Text(
                          'No categories found',
                          style: TextStyle(color: Colors.grey.shade600),
                        )
                      else
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.availableCategories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              final cat = widget.availableCategories[index];
                              final id = cat['id'].toString();
                              final name = (cat['name'] ?? 'Unknown')
                                  .toString();
                              final active = _categoryId == id;

                              return _chip(
                                label: name,
                                active: active,
                                onTap: () => setState(() {
                                  _categoryId = active ? null : id;
                                }),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 18),

                      _sectionTitle('Area'),
                      _dropdown(
                        label: 'Country',
                        value: _country,
                        items: widget.areasTree,
                        enabled: true,
                        onChanged: (v) {
                          setState(() {
                            _country = v;
                            _gov = null;
                            _city = null;
                            _areaId = v?.id;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'Governorate',
                        value: _gov,
                        items: (_country?.children ?? const []),
                        enabled: _country != null,
                        onChanged: (v) {
                          setState(() {
                            _gov = v;
                            _city = null;
                            _areaId = v?.id;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      _dropdown(
                        label: 'City',
                        value: _city,
                        items: (_gov?.children ?? const []),
                        enabled: _gov != null,
                        onChanged: (v) {
                          setState(() {
                            _city = v;
                            _areaId = v?.id;
                          });
                        },
                      ),

                      const SizedBox(height: 18),

                      _sectionTitle('Price Range'),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _minController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Min',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) =>
                                  _minPrice = double.tryParse(v.trim()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _maxController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (v) =>
                                  _maxPrice = double.tryParse(v.trim()),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      //popular
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Popular only'),
                          value: _popular,
                          activeColor: AppColor.primary,
                          activeTrackColor: AppColor.primary.withOpacity(0.35),
                          onChanged: (v) => setState(() => _popular = v),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Include Services
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Include Services'),
                          value: _incServicesUI,
                          activeColor: AppColor.primary,
                          activeTrackColor: AppColor.primary.withOpacity(0.35),
                          onChanged: (v) => setState(() {
                            _incServicesUI = v;
                            if (!v && !_incPackagesUI) _incPackagesUI = true;
                          }),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Include Packages 
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Include Packages'),
                          value: _incPackagesUI,
                          activeColor: AppColor.primary,
                          activeTrackColor: AppColor.primary.withOpacity(0.35),
                          onChanged: (v) => setState(() {
                            _incPackagesUI = v;
                            if (!v && !_incServicesUI) _incServicesUI = true;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sticky Apply Button
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _apply,
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? AppColor.primary.withOpacity(0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColor.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: active ? AppColor.primary : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required AreaNode? value,
    required List<AreaNode> items,
    required bool enabled,
    required ValueChanged<AreaNode?> onChanged,
  }) {
    return DropdownButtonFormField<AreaNode>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      items: items
          .map((e) => DropdownMenuItem<AreaNode>(value: e, child: Text(e.name)))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _FilterResult {
  final String? type;
  final String? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final bool popular;

  // null => don't send
  final bool? includeServices;
  final bool? includePackages;

  final AreaNode? selectedCountry;
  final AreaNode? selectedGov;
  final AreaNode? selectedCity;
  final int? selectedAreaId;

  const _FilterResult({
    required this.type,
    required this.categoryId,
    required this.minPrice,
    required this.maxPrice,
    required this.popular,
    required this.includeServices,
    required this.includePackages,
    required this.selectedCountry,
    required this.selectedGov,
    required this.selectedCity,
    required this.selectedAreaId,
  });
}
