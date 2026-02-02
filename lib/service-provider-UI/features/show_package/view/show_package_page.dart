import 'package:eventak/service-provider-UI/features/show_package/view/edit_package_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';
import '../data/package_details_model.dart';
import '../widgets/package_display_items_list.dart'; 

class ShowPackagePage extends StatefulWidget {
  final int packageId;
  const ShowPackagePage({super.key, required this.packageId});

  @override
  State<ShowPackagePage> createState() => _ShowPackagePageState();
}

class _ShowPackagePageState extends State<ShowPackagePage> {
  final DashboardService _api = DashboardService();
  PackageDetails? _package;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() { _loading = true; });
    try {
      final updated = await _api.getPackageDetails(widget.packageId);
      if (mounted) setState(() => _package = updated);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Package?'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        await _api.deletePackage(widget.packageId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package deleted successfully'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    }
  }

  Future<void> _onEdit() async {
    final availableServices = await _api.getMyServices();
    if (!mounted) return;
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPackageView(
          package: _package!, 
          availableServices: availableServices
        ),
      ),
    );
    if (changed == true) _refresh(); 
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _package == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (_package == null) {
      return const Scaffold(body: Center(child: Text("Package not found")));
    }

    final p = _package!;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('Package Details', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColor.blueFont,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _onEdit,
                  icon: const Icon(Icons.edit_outlined), 
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColor.primary),
                    foregroundColor: AppColor.primary
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
                    backgroundColor: Colors.redAccent, 
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMainHeader(p),
            const SizedBox(height: 16),
            if (p.pricingConfig != null) _buildPricingSection(p),
            const SizedBox(height: 16),
            _buildAreasSection(p),
            const SizedBox(height: 16),
            PackageDisplayItemsList(items: p.items),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader(PackageDetails p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(p.name, style: TextStyle(color: AppColor.blueFont, fontSize: 22, fontWeight: FontWeight.bold))),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(p.averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(' (${p.reviewsCount})', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (p.categories.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.categories.map((cat) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColor.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: Text(cat, style: TextStyle(color: AppColor.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          const SizedBox(height: 16),
          Text('${p.price.toStringAsFixed(2)} EGP', style: TextStyle(color: AppColor.primary, fontSize: 20, fontWeight: FontWeight.w800)),
          const Divider(height: 32),
          const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(p.description ?? 'No description provided.', style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
          if (p.provider != null) ...[
            const Divider(height: 32),
            Row(
              children: [
                CircleAvatar(radius: 20, backgroundImage: NetworkImage(p.provider!.avatar ?? ''), backgroundColor: Colors.grey.shade200),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Provider', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(p.provider!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSection(PackageDetails p) {
    final c = p.pricingConfig!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pricing Configuration", style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _infoRow("Overtime Rate", "${c.overtimeRate} EGP/hr"),
          if (c.maxDuration != null) _infoRow("Max Duration", "${c.maxDuration} hrs"),
          const Divider(),
          _infoRow("Base Capacity", "${p.capacity} Guests"),
          _infoRow("Fixed Capacity", p.fixedCapacity ? "Yes" : "No"),
          if (!p.fixedCapacity) ...[
            _infoRow("Capacity Step", "${c.capacityStep} Guests"),
            _infoRow("Step Fee", "${c.stepFee} EGP"),
            if (c.maxCapacity != null) _infoRow("Max Capacity Limit", "${c.maxCapacity} Guests"),
          ],
        ],
      ),
    );
  }

  Widget _buildAreasSection(PackageDetails p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Available Areas", style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: p.availableAreas.map((area) => Chip(
              label: Text(area['name'], style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.grey.shade100,
              avatar: const Icon(Icons.location_on, size: 14, color: Colors.orange),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}