import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/packages/packages_list/data/list_package_service.dart';
import 'package:eventak/customer-UI/features/packages/package_details/data/package_model.dart';
import 'package:eventak/customer-UI/features/packages/packages_list/widgets/event_categories_tabs.dart';
import 'package:eventak/customer-UI/features/packages/packages_list/widgets/package_card.dart';
import 'package:eventak/customer-UI/features/packages/packages_list/data/dummy_event_categories.dart';
import 'package:eventak/shared/prev_page_button.dart';

class PackagesListView extends StatefulWidget {
  final String selectedCategory;

  const PackagesListView({super.key, required this.selectedCategory});

  @override
  State<PackagesListView> createState() => _PackagesListViewState();
}

class _PackagesListViewState extends State<PackagesListView> {
  final ListPackagesService _service = ListPackagesService();
  final ScrollController _scrollController = ScrollController();

  List<PackageData> _packages = [];
  int _selectedCategoryId = 0;
  int _currentPage = 1;
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    
    _selectedCategoryId = dummyPackageCategories
        .firstWhere(
          (c) => c.name == widget.selectedCategory,
          orElse: () => dummyPackageCategories[0],
        )
        .id;

    _loadPackages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore && _hasMore && _error == null) {
        _loadMore();
      }
    }
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final data = await _service.fetchPackages(page: 1);
      setState(() {
        _packages = data;
        _isLoading = false;
        if (data.length < 15) _hasMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isFetchingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final data = await _service.fetchPackages(page: nextPage);

      setState(() {
        _packages.addAll(data);
        _currentPage = nextPage;
        _isFetchingMore = false;
        if (data.length < 15) _hasMore = false;
      });
    } catch (e) {
      setState(() => _isFetchingMore = false);
    }
  }

  List<PackageData> get _filteredPackages {
  if (_selectedCategoryId == 0) return _packages;

  final selectedCategoryName = dummyPackageCategories
      .firstWhere((c) => c.id == _selectedCategoryId)
      .name;

  return _packages
      .where((p) => p.categories.contains(selectedCategoryName))
      .toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.beige,
        elevation: 0,
        leading: PrevPageButton(size: 32), 
        title: const Text(
          'Packages',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          EventCategoriesTabs(
            categories: dummyPackageCategories,
            selectedId: _selectedCategoryId,
            onSelect: (id) {
              setState(() => _selectedCategoryId = id);
            },
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(_error!),
            TextButton(onPressed: _loadPackages, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredPackages.isEmpty) {
      return const Center(child: Text('No packages found'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredPackages.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _filteredPackages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return PackageCard(package: _filteredPackages[index]);
      },
    );
  }
}
