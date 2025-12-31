import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';
import '../data/package_details_model.dart';
import '../widgets/package_dialogs.dart';

class EditPackageView extends StatefulWidget {
  final PackageDetails package;
  final List<Map<String, dynamic>> availableServices;

  const EditPackageView({
    super.key,
    required this.package,
    required this.availableServices,
  });

  @override
  State<EditPackageView> createState() => _EditPackageViewState();
}

class _EditPackageViewState extends State<EditPackageView> {
  final _formKey = GlobalKey<FormState>();
  final DashboardService _api = DashboardService();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  bool _isLoading = false;
  late List<PackageItem> _currentItems;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package.name);
    _descController = TextEditingController(text: widget.package.description);
    _priceController = TextEditingController(text: widget.package.price.toString());
    _currentItems = List.from(widget.package.items);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _silentRefresh() async {
    try {
      final updated = await _api.getPackageDetails(widget.package.id);
      if (mounted) {
        setState(() {
          _currentItems = List.from(updated.items);
        });
      }
    } catch (e) {
      debugPrint("Silent refresh failed: $e");
    }
  }

  Future<void> _updateItemQuantity(PackageItem item, int newQuantity) async {
    try {
      await _api.updatePackageItem(widget.package.id, item.id, newQuantity); 
      await _silentRefresh(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddServiceDialog(
        availableServices: widget.availableServices,
        onAdd: (serviceId, quantity) async {
          try {
            await _api.addPackageItem(widget.package.id, serviceId, quantity); 
            await _silentRefresh();
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      ),
    );
  }

  void _showQuantityDialog(PackageItem item) {
    showDialog(
      context: context,
      builder: (ctx) => UpdateQuantityDialog(
        initialQuantity: item.quantity,
        onUpdate: (newQuantity) => _updateItemQuantity(item, newQuantity),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Package must have at least one service")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _api.updatePackage(widget.package.id, {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "price": double.tryParse(_priceController.text) ?? 0.0,
      }); 
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Edit Package", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColor.blueFont,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Package Name"),
                    style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "Price (EGP)"),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Included Services", style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton.icon(
                  onPressed: _showAddServiceDialog,
                  icon: Icon(Icons.add, color: AppColor.primary),
                  label: Text("Add Service", style: TextStyle(color: AppColor.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._currentItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("Quantity: ${item.quantity}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(icon: Icon(Icons.edit_outlined, color: AppColor.blueFont, size: 20), onPressed: () => _showQuantityDialog(item)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () async {
                      if (_currentItems.length > 1) {
                        await _api.deletePackageItem(widget.package.id, item.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Package must have at least one service")));
                      }
                    },
                  ),
                ],
              ),
            )),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Package Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}