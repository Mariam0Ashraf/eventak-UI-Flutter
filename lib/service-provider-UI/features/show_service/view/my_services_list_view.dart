import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_api.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/show_service_view.dart';

class MyServicesListPage extends StatefulWidget {
  const MyServicesListPage({super.key});

  @override
  State<MyServicesListPage> createState() => _MyServicesListPageState();
}

class _MyServicesListPageState extends State<MyServicesListPage> {
  final MyServicesService _serviceApi = MyServicesService();
  final ScrollController _scrollController = ScrollController();

  List<MyService> _services = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  int _currentServicePage = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialServices();
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
        _loadMoreServices();
      }
    }
  }

  Future<void> _loadInitialServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentServicePage = 1;
      _hasMoreData = true;
    });

    try {
      final data = await _serviceApi.listServices(page: _currentServicePage);
      if (!mounted) return;
      setState(() {
        _services = data;
        _isLoading = false;
        if (data.length < 15) _hasMoreData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _loadMoreServices() async {
    setState(() => _isFetchingMore = true);
    
    try {
      final nextPage = _currentServicePage + 1;
      final data = await _serviceApi.listServices(page: nextPage);
      
      if (!mounted) return;
      
      setState(() {
        if (data.isEmpty) {
          _hasMoreData = false;
        } else {
          _services.addAll(data); 
          _currentServicePage = nextPage;
          if (data.length < 15) _hasMoreData = false;
        }
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() => _isFetchingMore = false);
      debugPrint("Error fetching more services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.blueFont),
        title: Text(
          'My Services',
          style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialServices,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                : _services.isEmpty
                    ? const Center(child: Text('No services found.'))
                    : ListView.separated(
                        controller: _scrollController, 
                        padding: const EdgeInsets.all(16),
                        itemCount: _services.length + (_hasMoreData ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _services.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final s = _services[index];
                          return InkWell(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ShowServicePage(service: s)),
                              );
                              _loadInitialServices();
                            },
                            child: _ServiceListTile(service: s),
                          );
                        },
                      ),
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  final MyService service;
  const _ServiceListTile({required this.service});

  @override
  Widget build(BuildContext context) {
    String formatPriceUnit(String? unit) {
      if (unit == null || unit.isEmpty) return '';
      String spaced = unit.replaceAll('_', ' ');
      return spaced[0].toUpperCase() + spaced.substring(1);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 110,
                child: Image.network(
                  (service.image != null && service.image!.isNotEmpty) 
                      ? service.image! 
                      : 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.name, 
                            style: TextStyle(
                              color: AppColor.blueFont, 
                              fontSize: 16, 
                              fontWeight: FontWeight.w600
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          service.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11, 
                            color: service.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.category_outlined, size: 12, color: AppColor.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            service.serviceTypeName ?? 'General',
                            style: TextStyle(color: AppColor.grey, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.people_outline, size: 14, color: AppColor.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${service.capacity ?? 0}',
                          style: TextStyle(color: AppColor.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (service.basePrice != null)
                      Text(
                        '${service.basePrice!.toStringAsFixed(2)} EGP ${formatPriceUnit(service.priceUnit)}',
                        style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                    const SizedBox(height: 4),
                    if (service.location?.isNotEmpty ?? false)
                      Row(children: [
                        const Icon(Icons.location_on_outlined, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            service.location!, 
                            style: const TextStyle(fontSize: 11), 
                            overflow: TextOverflow.ellipsis
                          )
                        ),
                      ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}