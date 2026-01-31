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
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  final TextEditingController _includedHoursController = TextEditingController();
  final TextEditingController _overtimeRateController = TextEditingController();
  final TextEditingController _maxDurationController = TextEditingController();
  final TextEditingController _capacityStepController = TextEditingController();
  final TextEditingController _stepFeeController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _fixedCapacity = true; 

  late PaginationHandler<Map<String, dynamic>> _servicesPagination;
  late PaginationHandler<Map<String, dynamic>> _categoriesPagination;

  final List<Map<String, dynamic>> _packageItems = [];
  final List<int> _selectedCategoryIds = [];
  List<Map<String, dynamic>> _areaTree = [];
  List<List<int?>> _availableAreaPaths = [[]];

  @override
  void initState() {
    super.initState();
    _servicesPagination = PaginationHandler(fetchData: (page) => _apiService.fetchListData('my-services', page));
    _categoriesPagination = PaginationHandler(fetchData: (page) => _apiService.fetchListData('service-categories', page));
    _servicesPagination.fetchNextPage();
    _categoriesPagination.fetchNextPage();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    final areas = await _apiService.getAreasTree();
    setState(() => _areaTree = areas);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _capacityController.dispose();
    _includedHoursController.dispose();
    _overtimeRateController.dispose();
    _maxDurationController.dispose();
    _capacityStepController.dispose();
    _stepFeeController.dispose();
    _maxCapacityController.dispose();
    super.dispose();
  }

  Widget _buildAvailableAreas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableAreaPaths.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Area ${index + 1}"),
                        if (_availableAreaPaths.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _availableAreaPaths.removeAt(index)),
                          )
                      ],
                    ),
                    _buildAvailableAreaDropdowns(index),
                  ],
                ),
              ),
            );
          },
        ),
        TextButton.icon(
          onPressed: () => setState(() => _availableAreaPaths.add([])),
          icon: const Icon(Icons.add),
          label: const Text("Add Another Available Area"),
        ),
      ],
    );
  }

  Widget _buildAvailableAreaDropdowns(int pathIndex) {
    List<int?> path = _availableAreaPaths[pathIndex];
    List<Widget> widgets = [];
    List<Map<String, dynamic>> currentItems = _areaTree;

    for (int i = 0; i <= path.length; i++) {
      if (currentItems.isEmpty) break;
      int? selectedId = i < path.length ? path[i] : null;
      String typeName = currentItems.first['type'] ?? 'Area';

      widgets.add(
        CustomDropdownField<int>(
          label: "${typeName[0].toUpperCase() + typeName.substring(1)} ${i > 0 ? '(Optional)' : ''}",
          value: selectedId,
          hintText: 'Select $typeName',
          validator: i == 0 ? (val) => val == null ? 'Country is required' : null : null,
          items: currentItems.map((area) => DropdownMenuItem<int>(value: area['id'], child: Text(area['name']))).toList(),
          onChanged: (val) {
            setState(() {
              List<int?> newPath = i < path.length ? path.sublist(0, i) : List<int?>.from(path);
              if (val != null) newPath.add(val);
              _availableAreaPaths[pathIndex] = newPath;
            });
          },
        ),
      );

      if (selectedId != null) {
        try {
          var node = currentItems.firstWhere((item) => item['id'] == selectedId);
          currentItems = List<Map<String, dynamic>>.from(node['children'] ?? []);
        } catch (e) {
          currentItems = [];
        }
      } else {
        break;
      }
    }
    return Column(children: widgets);
  }

  Future<void> _submitPackage() async {
    if (!_formKey.currentState!.validate()) return;
    if (_packageItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    setState(() => _isLoading = true);

    final List<int> availabilityIds = _availableAreaPaths
        .where((p) => p.isNotEmpty)
        .map((p) => p.last!)
        .toList();

    final packageData = {
      "name": _nameController.text.trim(),
      "description": _descController.text.trim(),
      "base_price": double.tryParse(_basePriceController.text) ?? 0.0,
      "capacity": int.tryParse(_capacityController.text) ?? 0,
      "fixed_capacity": _fixedCapacity,
      "is_active": _isActive,
      "category_ids": _selectedCategoryIds,
      "available_area_ids": availabilityIds,
      "pricing_config": {
        "included_hours": int.tryParse(_includedHoursController.text),
        "overtime_rate": double.tryParse(_overtimeRateController.text),
        "max_duration": int.tryParse(_maxDurationController.text),
        if (!_fixedCapacity) ...{
          "capacity_step": int.tryParse(_capacityStepController.text),
          "step_fee": double.tryParse(_stepFeeController.text),
          "max_capacity": int.tryParse(_maxCapacityController.text),
        }
      },
      "items": _packageItems.map((item) => {
            "service_id": item['service_id'],
            "quantity": item['quantity'],
          }).toList(),
    };

    try {
      final success = await _apiService.createPackage(packageData);
      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
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
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: _basePriceController, label: 'Base Price', keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(controller: _capacityController, label: 'Capacity (Guests)', keyboardType: TextInputType.number)),
                ],
              ),

              SwitchListTile(
                title: const Text('Fixed Capacity', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('False allows variable capacity with surcharges'),
                value: _fixedCapacity,
                activeColor: AppColor.primary,
                onChanged: (val) => setState(() => _fixedCapacity = val),
              ),

              if (!_fixedCapacity) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Variable Capacity Pricing", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
                Row(
                  children: [
                    Expanded(child: CustomTextField(
                      controller: _capacityStepController, 
                      label: 'Capacity Step', 
                      hint: 'e.g. 10 guests per step',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextField(
                      controller: _stepFeeController, 
                      label: 'Step Fee', 
                      hint: 'Price per step',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    )),
                  ],
                ),
                CustomTextField(controller: _maxCapacityController, label: 'Max Capacity (Optional)', validator: (v) => null),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Service Duration Pricing", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
                Row(
                  children: [
                    Expanded(child: CustomTextField(
                      controller: _includedHoursController, 
                      label: 'Included Hours',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextField(
                      controller: _overtimeRateController, 
                      label: 'Overtime Rate',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    )),
                  ],
                ),
                CustomTextField(controller: _maxDurationController, label: 'Max Duration (Optional)', validator: (v) => null),
              ],

              const SizedBox(height: 16),
              const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCategorySelector(),

              const SizedBox(height: 24),
              _buildAvailableAreas(),

              const SizedBox(height: 24),
              const Text("Package Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  selected ? _selectedCategoryIds.add(cat['id']) : _selectedCategoryIds.remove(cat['id']);
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}