import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';
import 'package:eventak/service-provider-UI/features/show_package/view/show_package_page.dart';
import '../widgets/package_list_tile.dart';

class MyPackagesListPage extends StatefulWidget {
  const MyPackagesListPage({super.key});

  @override
  State<MyPackagesListPage> createState() => _MyPackagesListPageState();
}

class _MyPackagesListPageState extends State<MyPackagesListPage> {
  final DashboardService _api = DashboardService();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialPackages();
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
        _loadMorePackages();
      }
    }
  }

  Future<void> _loadInitialPackages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _hasMoreData = true;
    });

    try {
      final data = await _api.getPackages(page: _currentPage);
      if (!mounted) return;
      setState(() {
        _packages = data;
        _isLoading = false;
        if (data.length < 15) _hasMoreData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMorePackages() async {
    setState(() => _isFetchingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final data = await _api.getPackages(page: nextPage);
      if (!mounted) return;
      setState(() {
        if (data.isEmpty) {
          _hasMoreData = false;
        } else {
          _packages.addAll(data);
          _currentPage = nextPage;
          if (data.length < 15) _hasMoreData = false;
        }
        _isFetchingMore = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('All Packages', style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColor.blueFont),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialPackages,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _packages.isEmpty
                ? const Center(child: Text("No packages found."))
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _packages.length + (_hasMoreData ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == _packages.length) {
                        return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                      }
                      final p = _packages[index];
                      return PackageListTile(
                        package: p,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ShowPackagePage(packageId: p['id'])),
                          );
                          _loadInitialPackages(); 
                        },
                      );
                    },
                  ),
      ),
    );
  }
}