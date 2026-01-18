import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/pagination_handler.dart'; 
import 'package:eventak/service-provider-UI/features/add_pacakge/data/add_package_service.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_items_list.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_item_form.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class AddPackageView extends StatefulWidget {
  final List<Map<String, dynamic>>? services;

  const AddPackageView({super.key, this.services});

  @override
  State<AddPackageView> createState() => _AddPackageViewState();
}

class _AddPackageViewState extends State<AddPackageView> {
  final _formKey = GlobalKey<FormState>();
  final AddPackageService _apiService = AddPackageService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  late PaginationHandler<Map<String, dynamic>> _servicesPagination;
  late PaginationHandler<Map<String, dynamic>> _categoriesPagination;

  final List<Map<String, dynamic>> _packageItems = [];
  final List<int> _selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();

    _servicesPagination = PaginationHandler(
      fetchData: (page) => _apiService.fetchListData('my-services', page),
    );

    _categoriesPagination = PaginationHandler(
      fetchData: (page) => _apiService.fetchListData('service-categories', page),
    );

    _servicesPagination.fetchNextPage();
    _categoriesPagination.fetchNextPage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _servicesPagination.dispose();
    _categoriesPagination.dispose();
    super.dispose();
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
      "category_ids": _selectedCategoryIds,
      "items": _packageItems.map((item) => {
            "service_id": item['service_id'],
            "quantity": item['quantity'],
          }).toList(),
    };

    try {
      final success = await _apiService.createPackage(packageData);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package created!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(controller: _nameController, label: 'Package Name'),
              CustomTextField(controller: _descController, label: 'Description', maxLines: 3),
              
              const SizedBox(height: 16),
              const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCategorySelector(),

              const SizedBox(height: 24),
              const Text("Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              
              PackageItemForm(
                servicesNotifier: _servicesPagination.dataNotifier, 
                onAdd: (item) => setState(() => _packageItems.add(item)),
                onLoadMore: _servicesPagination.fetchNextPage,
                hasMore: _servicesPagination.hasMore,
                isLoadingMore: _servicesPagination.isFetching,
              ),

              const SizedBox(height: 12),
              PackageItemsList(
                items: _packageItems, 
                onRemove: (index) => setState(() => _packageItems.removeAt(index))
              ),
              
              const SizedBox(height: 24),
              CustomTextField(controller: _priceController, label: 'Price', keyboardType: TextInputType.number),
              
              SwitchListTile(
                title: const Text('Active Status'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPackage,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Create Package', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _categoriesPagination.dataNotifier,
      builder: (context, categories, _) {
        return Wrap(
          spacing: 8,
          children: categories.map((cat) {
            final isSelected = _selectedCategoryIds.contains(cat['id']);
            return FilterChip(
              label: Text(cat['name'] ?? ''),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected 
                    ? _selectedCategoryIds.add(cat['id']) 
                    : _selectedCategoryIds.remove(cat['id']);
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}