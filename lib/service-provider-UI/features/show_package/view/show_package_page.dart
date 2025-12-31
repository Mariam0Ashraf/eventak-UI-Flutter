
import 'package:eventak/service-provider-UI/features/show_package/view/edit_package_view.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';
import '../data/package_details_model.dart';
import '../widgets/package_widgets.dart';

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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _package == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final p = _package!;

    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text('Package Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColor.blueFont,
        elevation: 0,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : _onEdit,
                  icon: const Icon(Icons.edit), 
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _onDelete, 
                  icon: _loading 
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.delete), 
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: TextStyle(color: AppColor.blueFont, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${p.price.toStringAsFixed(2)} EGP', 
                    style: TextStyle(color: AppColor.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(p.description ?? 'No description provided.', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PackageItemsList(items: p.items),
          ],
        ),
      ),
    );
  }
Future<void> _onEdit() async {
  final availableServices = await _api.getMyServices(); 
  
  final changed = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditPackageView(
        package: _package!, 
        availableServices: availableServices
      ),
    ),
  );

  if (changed == true) {
    _refresh(); 
  }
}
}