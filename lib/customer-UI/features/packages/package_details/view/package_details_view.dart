import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/shared/app_bar_widget.dart';
import 'package:eventak/shared/prev_page_button.dart';

import 'package:eventak/customer-UI/features/packages/package_details/data/package_model.dart';
import 'package:eventak/customer-UI/features/packages/package_details/data/package_details_service.dart';
import 'package:eventak/customer-UI/features/packages/package_details/widgets/book_package.dart';
import 'package:eventak/customer-UI/features/packages/package_details/widgets/included_services_list.dart';
import 'package:eventak/customer-UI/features/packages/package_details/widgets/package_info.dart';
import 'package:eventak/customer-UI/features/services/service_details/widgets/reviews_tab.dart';

class PackageDetailsView extends StatefulWidget {
  final int packageId;
  final VoidCallback? onReviewChanged;

  const PackageDetailsView({
    super.key,
    required this.packageId,
    this.onReviewChanged,
  });

  @override
  State<PackageDetailsView> createState() => _PackageDetailsViewState();
}

class _PackageDetailsViewState extends State<PackageDetailsView> {
  final _api = PackageDetailsService();
  PackageData? _package;
  bool _loading = true;
  bool _isProvider = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
    _loadPackage();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role')?.toLowerCase();
    if (mounted) {
      setState(() {
        _isProvider = role == 'provider';
      });
    }
  }

  Future<void> _loadPackage() async {
    try {
      final res = await _api.getPackage(widget.packageId);
      setState(() {
        _package = PackageData.fromJson(res['data']);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      debugPrint('Error loading package: $e');
    }
  }

  void _openBooking() {
    if (_package == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BookPackageSheet(package: _package!),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_package == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load package')),
      );
    }

    final package = _package!;
    debugPrint('Items count: ${package.items.length}');

    return Scaffold(
      appBar: const CustomHomeAppBar(showBackButton: true),
      bottomNavigationBar: _isProvider 
        ? null 
        : Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _openBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Book Package'),
            ),
          ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      package.name,
                      style:  TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColor.blueFont,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            PackageInfoSection(package: package),

            IncludedServicesList(items: package.items),

            const SizedBox(height: 20),

            SizedBox(
              height: 500,
              child: ReviewsTab(
                reviewableId: package.id,
                reviewableType: 'package',
                onReviewChanged: _loadPackage,
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}