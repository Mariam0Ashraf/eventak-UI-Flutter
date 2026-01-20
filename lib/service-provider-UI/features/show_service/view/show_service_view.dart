import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_api.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/edit_service_view.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/service_reviews_view.dart';
import 'package:eventak/service-provider-UI/features/show_service/widgets/show_service_widgets.dart';

class ShowServicePage extends StatefulWidget {
  final MyService service;
  const ShowServicePage({super.key, required this.service});

  @override
  State<ShowServicePage> createState() => _ShowServicePageState();
}

class _ShowServicePageState extends State<ShowServicePage> {
  final MyServicesService _api = MyServicesService();
  late MyService _service;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final updated = await _api.getService(_service.id);
      if (!mounted) return;
      setState(() => _service = updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception:', '').trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onEdit() async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditServiceView(service: _service)),
    );
    if (changed == true) await _refresh();
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Delete service?'),
            content: const Text('Are you sure you want to delete this service?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(dialogCtx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ?? false;

    if (!confirm) return;
    try {
      setState(() => _loading = true);
      await _api.deleteService(_service.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service deleted successfully'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String formatPriceUnit(String? unit) {
    if (unit == null || unit.isEmpty) return '';
    String spaced = unit.replaceAll('_', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final s = _service;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.blueFont),
        title: Text('Service Details', style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomAction(context),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            if (s.galleryUrls.isNotEmpty) _buildGallery(s.galleryUrls),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null) ServiceErrorCard(message: _error!),

            ServiceDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: TextStyle(color: AppColor.blueFont, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (s.categoryName != null)
                        ServicePill(text: s.categoryName!, bg: Colors.purple.withOpacity(0.1), fg: Colors.purple, icon: Icons.grid_view_rounded),
                      
                      if (s.serviceTypeName != null)
                        ServicePill(text: s.serviceTypeName!, bg: AppColor.primary.withOpacity(0.1), fg: AppColor.primary, icon: Icons.category_outlined),
                      
                      if (s.areaName != null && s.areaName!.isNotEmpty)
                        ServicePill(text: s.areaName!, bg: Colors.teal.withOpacity(0.1), fg: Colors.teal, icon: Icons.location_on_outlined),

                      ServicePill(text: formatPriceUnit(s.priceUnit), bg: Colors.blue.withOpacity(0.1), fg: Colors.blue, icon: Icons.timer_outlined),

                      ServicePill(
                        text: s.fixedCapacity ? 'Fixed Capacity' : 'Step Capacity',
                        bg: s.fixedCapacity ? Colors.blueGrey.withOpacity(0.1) : Colors.indigo.withOpacity(0.1),
                        fg: s.fixedCapacity ? Colors.blueGrey : Colors.indigo,
                        icon: s.fixedCapacity ? Icons.people : Icons.groups_outlined,
                      ),
                      
                      ServicePill(text: 'Stock: ${s.inventoryCount}', bg: Colors.orange.withOpacity(0.1), fg: Colors.orange, icon: Icons.inventory_2_outlined),
                      
                      ServicePill(
                        text: s.isActive ? 'Active' : 'Inactive',
                        bg: s.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        fg: s.isActive ? Colors.green : Colors.red,
                        icon: s.isActive ? Icons.check_circle : Icons.cancel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPriceSection(s),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (!s.fixedCapacity && s.pricingConfig != null)
              ServiceDetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pricing Configuration', 
                      style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: _infoBit('Step', s.pricingConfig!['capacity_step']?.toString() ?? '0')),
                        Flexible(child: _infoBit('Fee', '${s.pricingConfig!['step_fee']?.toString() ?? '0'} EGP')),
                        Flexible(child: _infoBit('Min', s.pricingConfig!['min_capacity']?.toString() ?? '0')),
                        Flexible(child: _infoBit('Max', s.pricingConfig!['max_capacity']?.toString() ?? '0')),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            ServiceDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(Icons.people_outline, 'Base Capacity', '${s.capacity ?? 0} Persons'),
                  const Divider(),
                  _detailRow(Icons.location_on_outlined, 'Address', s.address ?? 'N/A'),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text('Description', style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(s.description ?? 'No description provided.', style: TextStyle(color: AppColor.blueFont.withOpacity(0.7), height: 1.4)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            ServiceDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reviews', style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ServiceReviewsSection(serviceId: s.id, useDummyIfFailed: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGallery(List<String> urls) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(urls[index], width: MediaQuery.of(context).size.width * 0.85, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(MyService s) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: AppColor.primary),
          const SizedBox(width: 10),
          Text('${s.basePrice?.toStringAsFixed(2) ?? '0.00'} EGP', style: TextStyle(color: AppColor.primary, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Text('/ ${formatPriceUnit(s.priceUnit)}', style: TextStyle(color: AppColor.blueFont.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoBit(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.blueFont, fontSize: 14)),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColor.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Service'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
