import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/data/add_package_service.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_items_list.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_item_form.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';

class AddPackageView extends StatefulWidget {
  final List<Map<String, dynamic>>? services;

  const AddPackageView({super.key, this.services});

  @override
  State<AddPackageView> createState() => _AddPackageViewState();
}

class _AddPackageViewState extends State<AddPackageView> {
  final _formKey = GlobalKey<FormState>();
  final AddPackageService _service = AddPackageService();
  final DashboardService _dashboardService = DashboardService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  final ValueNotifier<List<Map<String, dynamic>>> _availableServicesNotifier = 
      ValueNotifier<List<Map<String, dynamic>>>([]);
      
  int _currentServicePage = 1;
  bool _isFetchingServices = false;
  bool _hasMoreServices = true;

  final List<Map<String, dynamic>> _packageItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.services != null && widget.services!.isNotEmpty) {
      _availableServicesNotifier.value = List.from(widget.services!);
      if (_availableServicesNotifier.value.length < 15) _hasMoreServices = false;
      _currentServicePage = 2;
    } else {
      _fetchPaginatedServices();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _availableServicesNotifier.dispose(); 
    super.dispose();
  }

  Future<void> _fetchPaginatedServices() async {
    if (_isFetchingServices || !_hasMoreServices) return;

    setState(() => _isFetchingServices = true);
    try {
      final newServices = await _dashboardService.getMyServices(page: _currentServicePage);
      
      if (mounted) {
        if (newServices.isEmpty) {
          setState(() => _hasMoreServices = false);
        } else {
          _availableServicesNotifier.value = [..._availableServicesNotifier.value, ...newServices];
          
          setState(() {
            _currentServicePage++;
            if (newServices.length < 15) _hasMoreServices = false;
          });
        }
      }
    } catch (e) {
      debugPrint(" Error fetching services: $e");
    } finally {
      if (mounted) setState(() => _isFetchingServices = false);
    }
  }

  Future<void> _submitPackage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_packageItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    setState(() => _isLoading = true);
    final packageData = {
      "name": _nameController.text.trim(),
      "description": _descController.text.trim(),
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "is_active": _isActive,
    };

    try {
      final packageId = await _service.createPackage(packageData);
      for (final item in _packageItems) {
        await _service.addPackageItem(
          packageId: packageId,
          serviceId: item['service_id'],
          itemDescription: item['item_description'] ?? "",
          quantity: item['quantity'],
          priceAdjustment: item['price_adjustment'] ?? 0.0,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Package created!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Package', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _nameController, label: 'Package Name', hint: 'Gold Wedding Package', validator: (v) => v!.isEmpty ? 'Required' : null),
              CustomTextField(controller: _descController, label: 'Description', maxLines: 4, validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 24),
              
              PackageItemForm(
                servicesNotifier: _availableServicesNotifier, 
                onAdd: (item) => setState(() => _packageItems.add(item)),
                onLoadMore: _fetchPaginatedServices,
                hasMore: _hasMoreServices,
                isLoadingMore: _isFetchingServices,
              ),

              const SizedBox(height: 12),
              PackageItemsList(items: _packageItems, onRemove: (index) => setState(() => _packageItems.removeAt(index))),
              const SizedBox(height: 24),
              CustomTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPackage,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, foregroundColor: Colors.white),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Package'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}