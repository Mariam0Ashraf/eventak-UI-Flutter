import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/customer-UI/features/services/service_details/widgets/portofolio_tab.dart';
import 'package:eventak/customer-UI/features/services/service_details/widgets/reviews_tab.dart';
import 'package:eventak/customer-UI/features/services/service_details/widgets/service_images_slider.dart';
import 'package:eventak/customer-UI/features/services/service_details/widgets/service_info_tab.dart';
import 'package:eventak/shared/prev_page_button.dart';
import 'package:eventak/customer-UI/features/services/service_details/widgets/book_service_tab.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/service_model.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/service_details_service.dart';
import 'package:eventak/customer-UI/features/services/service_details/widgets/service_images_slider.dart';
class ServiceDetailsView extends StatefulWidget {
  final int serviceId;
  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  State<ServiceDetailsView> createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  ServiceData? _service;
  bool _loading = true;
  bool _isProvider = false;
  final _serviceApi = ServiceDetailsService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role')?.toLowerCase();

    try {
      final res = await _serviceApi.getService(widget.serviceId);
      if (mounted) {
        setState(() {
          _isProvider = role == 'provider';
          _service = ServiceData.fromJson(res['data']);
          _tabController = TabController(length: _isProvider ? 3 : 4, vsync: this);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openGalleryViewer(BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "${initialIndex + 1} / ${images.length}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          body: PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.white, size: 50),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _tabController == null || _service == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const CustomHomeAppBar(showBackButton: true),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _service!.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_service!.galleryImages.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    ServiceImages(
                      service: _service!,
                      onImageTap: (index) {
                        _openGalleryViewer(context, _service!.galleryImages, index);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColor.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColor.primary,
                  tabs: [
                    const Tab(text: 'Details'),
                    const Tab(text: 'Portfolio'),
                    const Tab(text: 'Reviews'),
                    if (!_isProvider) const Tab(text: 'Book'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            ServiceInfoTab(service: _service!),
            const PortfolioTab(),
            ReviewsTab(
              reviewableId: widget.serviceId,
              reviewableType: 'service',
              onReviewChanged: _initializeData,
            ),
            if (!_isProvider) BookServiceTab(service: _service!),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: _tabBar,
    );
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}