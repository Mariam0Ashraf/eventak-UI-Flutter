import 'dart:async';
import 'package:eventak/customer-UI/features/home/data/home_service.dart';
import 'package:eventak/customer-UI/features/home/data/search_service.dart';
import 'package:eventak/customer-UI/features/home/data/search_result_model.dart';
import 'package:eventak/customer-UI/features/home/widgets/search_result_tile.dart';
import 'package:eventak/customer-UI/features/packages/package_details/view/package_details_view.dart';
import 'package:eventak/customer-UI/features/services/service_details/view/service_details_view.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';

import 'package:eventak/customer-UI/features/home/data/areas_service.dart';
import 'package:eventak/customer-UI/features/home/view/area_view.dart';
import 'package:eventak/customer-UI/features/home/widgets/search_filter_sheet.dart';
import 'package:eventak/customer-UI/features/home/view/filter_result.dart';

enum SortOption { latest, oldest, priceLowToHigh, priceHighToLow, topRated }

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

  // Service Types
  List<Map<String, dynamic>> _availableServiceTypes = [];
  String? _serviceTypeId;

  // Filters
  bool _isLoading = false;
  bool _loadingMore = false;

  String _query = '';
  String? _category; // category id as string
  double? _minPrice;
  double? _maxPrice;
  bool _popular = false;

  // sort (Front only)
  SortOption _sort = SortOption.latest;

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
    _fetchServiceTypes();
    _fetchAreas();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_loadingMore) {
        _loadMore();
      }
    });

    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialLoad();
    });
  }

  Future<void> _performInitialLoad() async {
    setState(() {
      _query = ''; // empty
      _results.clear();
      _servicesPage = 1;
      _packagesPage = 1;

      _includeServices = null;
      _includePackages = null;
      _category = null;
      _serviceTypeId = null;
      _selectedAreaId = null;
      _minPrice = null;
      _maxPrice = null;
      _popular = false;
    });

    await _performSearch(force: true);
  }

  Future<void> _fetchCategories() async {
    try {
      final results = await _homeService.getServiceCategories();
      if (mounted) setState(() => _availableCategories = results);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
  }

  Future<void> _fetchServiceTypes() async {
    try {
      final results = await _homeService.getServiceTypes();
      if (mounted) setState(() => _availableServiceTypes = results);
    } catch (e) {
      debugPrint("Error fetching service types: $e");
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

  Future<void> _performSearch({bool force = false}) async {
    final hasAnyFilter =
        _category != null ||
        _serviceTypeId != null ||
        _selectedAreaId != null ||
        _minPrice != null ||
        _maxPrice != null ||
        (_popular == true) ||
        (_includeServices != null) ||
        (_includePackages != null);

    if (!force && _query.isEmpty && !hasAnyFilter) return;

    setState(() => _isLoading = true);

    try {
      final data = await _searchService.search(
        query: _query,
        areaId: _selectedAreaId,
        categoryId: _category,
        serviceTypeId: _serviceTypeId, // ✅ NEW
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
        combined.addAll((data['services'] as List<SearchResult>?) ?? []);
        combined.addAll((data['packages'] as List<SearchResult>?) ?? []);

        _results.addAll(combined);
        _applySort();

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

    if (_servicesPage < _servicesLastPage) {
      _servicesPage++;
      _loadingMore = true;
      _performSearch();
    } else if (_packagesPage < _packagesLastPage) {
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
    final result = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SearchFilterSheet(
          availableCategories: _availableCategories,
          availableServiceTypes: _availableServiceTypes,
          areasTree: _areasTree,

          categoryId: _category,
          serviceTypeId: _serviceTypeId,
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
      _category = result.categoryId;
      _serviceTypeId = result.serviceTypeId;
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

  void _applySort() {
    setState(() {
      _results.sort((a, b) {
        switch (_sort) {
          case SortOption.latest:
            return b.id.compareTo(a.id); // fallback
          case SortOption.oldest:
            return a.id.compareTo(b.id);
          case SortOption.priceLowToHigh:
            return a.price.compareTo(b.price);
          case SortOption.priceHighToLow:
            return b.price.compareTo(a.price);
          case SortOption.topRated:
            final r = b.averageRating.compareTo(a.averageRating);
            if (r != 0) return r;
            return a.price.compareTo(b.price);
        }
      });
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<SortOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Sort by',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, SortOption.latest),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _sortTile('Latest', SortOption.latest),
                _sortTile('Oldest', SortOption.oldest),
                _sortTile('Price: Low → High', SortOption.priceLowToHigh),
                _sortTile('Price: High → Low', SortOption.priceHighToLow),
                _sortTile('Top Rated', SortOption.topRated),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    setState(() => _sort = selected);
    _applySort();
  }

  Widget _sortTile(String title, SortOption value) {
    final selected = _sort == value;

    return ListTile(
      onTap: () => Navigator.pop(context, value),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: selected
          ? Icon(Icons.check_circle, color: AppColor.primary)
          : Icon(Icons.circle_outlined, color: Colors.grey.shade400),
    );
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
            Tooltip(
              message: 'Sort by',
              child: InkWell(
                onTap: _openSortSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.swap_vert, color: AppColor.blueFont),
                ),
              ),
            ),
            Tooltip(
              message: 'Filters',
              child: InkWell(
                onTap: _openFilterSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: AppColor.blueFont,
                  ),
                ),
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
                    ? const Center(child: Text("No results found."))
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
