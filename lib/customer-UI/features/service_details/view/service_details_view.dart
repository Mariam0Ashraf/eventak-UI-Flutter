import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
//Import Widgets
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/portofolio_tab.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/reviews_tab.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/service_images_slider.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/service_info_tab.dart';
import 'package:eventak/shared/prev_page_button.dart';
import 'package:eventak/customer-UI/features/service_details/widgets/book_service_tab.dart';

//Import Data
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

    debugPrint(' serviceId = ${widget.serviceId}');
    _tabController = TabController(length: 4, vsync: this);
    _loadService();
  }

  Future<void> _loadService() async {
    try {
      final res = await _serviceApi.getService(widget.serviceId);

      debugPrint(' Service response received');
      debugPrint(res.toString());

      setState(() {
        _service = ServiceData.fromJson(res['data']);
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: const CustomHomeAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PrevPageButton(),

                const SizedBox(width: 8),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service!.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // ✅ LOCATION (تحت الاسم)
                      if ((_service!.location ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _service!.location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
              Tab(text: 'Book Service'),
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
                const BookServiceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
