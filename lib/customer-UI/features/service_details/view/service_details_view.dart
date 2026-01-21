import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/portofolio_tab.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/reviews_tab.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/service_images_slider.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/service_info_tab.dart';
import 'package:eventak/shared/prev_page_button.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/book_service_tab.dart';
import 'package:eventak/customer-UI/features/service_details/data/service_model.dart';
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
  ServiceData? _service;
  bool _loading = true;
  final _serviceApi = ServiceDetailsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadService();
  }

  Future<void> _loadService() async {
    try {
      final res = await _serviceApi.getService(widget.serviceId);
      setState(() {
        _service = ServiceData.fromJson(res['data']);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading service: $e');
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_service == null) {
      return const Scaffold(body: Center(child: Text("Service not found")));
    }

    return Scaffold(
      appBar: const CustomHomeAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const PrevPageButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _service!.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ServiceImages(service: _service!),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            labelColor: AppColor.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColor.primary,
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Portfolio'),
              Tab(text: 'Reviews'),
              Tab(text: 'Book'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ServiceInfoTab(service: _service!),
                PortfolioTab(),
                ReviewsTab(
                  reviewableId: widget.serviceId,
                  reviewableType: 'service',
                  onReviewChanged: _loadService,
                ),
                BookServiceTab(service: _service!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}