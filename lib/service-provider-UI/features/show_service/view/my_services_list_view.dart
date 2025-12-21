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
  final MyServicesService _service = MyServicesService();

  List<MyService> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.listServices();
      if (!mounted) return;
      setState(() {
        _services = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll(
          'Exception: ',
          'Failed to load services: ',
        );
      });
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
          style: TextStyle(
            color: AppColor.blueFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                )
              : _services.isEmpty
              ? const Center(child: Text('No services found.'))
              : ListView.separated(
                  itemCount: _services.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final s = _services[index];

                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShowServicePage(service: s),
                          ),
                        );
                        _loadServices();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: TextStyle(
                                color: AppColor.blueFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (s.basePrice != null)
                              Text(
                                '${s.basePrice!.toStringAsFixed(2)} ${s.priceUnit ?? ''}',
                                style: TextStyle(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 4),
                            if (s.location != null &&
                                s.location!.trim().isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      s.location!,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 4),
                            Text(
                              s.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: s.isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
