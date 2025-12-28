import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
//Import Widgets
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/portofolio_tab.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/reviews_tab.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/service_images_slider.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/service_info_tab.dart';

//Import Data
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:eventak/customer-UI/features/service_details/data/service_details_service.dart';

class ServiceDetailsView extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  MyService? _service;
  bool _loading = true;

final _serviceApi = ServiceDetailsService();

  @override
  void initState() {
  super.initState();
  debugPrint(' ServiceDetailsView opened');
  debugPrint(' serviceId = ${widget.serviceId}');
  _tabController = TabController(length: 3, vsync: this);
  _loadService();
}

Future<void> _loadService() async {
  try {
    debugPrint(' Loading service...');
    final res = await _serviceApi.getService(widget.serviceId);

    debugPrint(' Service response received');
    debugPrint(res.toString());

    setState(() {
      _service = MyService.fromJson(res['data']);
      _loading = false;
    });

    debugPrint('Service parsed successfully');
  } catch (e, stack) {
    debugPrint(' Error loading service');
    debugPrint(e.toString());
    debugPrint(stack.toString());

    setState(() => _loading = false);
  }
}


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     debugPrint('🔄 build() | loading=$_loading | service=$_service');
    if (_loading) {
      return const Scaffold(
       body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: const CustomHomeAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _service!.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          const ServiceImages(),

          const SizedBox(height: 10),

          TabBar(
            controller: _tabController,
            labelColor: AppColor.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColor.primary,
            tabs: const [
              Tab(text: 'Service Details'),
              Tab(text: 'Portfolio'),
              Tab(text: 'Reviews'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [ServiceInfoTab(service: _service!), PortfolioTab(), ReviewsTab(serviceId: widget.serviceId)],
            ),
          ),
        ],
      ),
    );
  }
}
