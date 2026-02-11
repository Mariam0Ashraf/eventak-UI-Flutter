import 'package:eventak/core/utils/app_alerts.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/pagination_handler.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/data/add_package_service.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/data/package_data_model.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_items_list.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_item_form.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_area_selector.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_widgets.dart';
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
  final TextEditingController _overtimeRateController = TextEditingController();

  final TextEditingController _inventoryController = TextEditingController();
  final TextEditingController _noticeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _bufferController = TextEditingController();

  final TextEditingController _capacityStepController = TextEditingController();
  final TextEditingController _stepFeeController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _maxDurationController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;
  bool _fixedCapacity = false; 

  late PaginationHandler<Map<String, dynamic>> _servicesPagination;
  late PaginationHandler<Map<String, dynamic>> _categoriesPagination;

  final List<Map<String, dynamic>> _packageItems = [];
  final List<int> _selectedCategoryIds = [];
  List<Map<String, dynamic>> _areaTree = [];
  List<List<int?>> _availableAreaPaths = [[]];

  @override
  void initState() {
    super.initState();
    _servicesPagination = PaginationHandler(
        fetchData: (page) => _apiService.fetchListData('my-services', page));
    _categoriesPagination = PaginationHandler(
        fetchData: (page) => _apiService.fetchListData('service-categories', page));
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
    _inventoryController.dispose();
    _noticeController.dispose();
    _durationController.dispose();
    _bufferController.dispose();
    _overtimeRateController.dispose();
    _capacityStepController.dispose();
    _stepFeeController.dispose();
    _maxCapacityController.dispose();
    _maxDurationController.dispose();
    super.dispose();
  }

  Future<void> _submitPackage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final List<int> availabilityIds = _availableAreaPaths
        .where((p) => p.isNotEmpty)
        .map((p) => p.last!)
        .toList();

    final packageRequest = PackageRequestModel(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      basePrice: double.tryParse(_basePriceController.text) ?? 0.0,
      capacity: int.tryParse(_capacityController.text) ?? 0,
      fixedCapacity: _fixedCapacity,
      inventoryCount: _inventoryController.text,
      minimumNoticeHours: _noticeController.text,
      minimumDurationHours: _durationController.text,
      bufferTimeMinutes: _bufferController.text,
      categoryIds: _selectedCategoryIds,
      availableAreaIds: availabilityIds,
      pricingConfig: {
        "overtime_rate": double.tryParse(_overtimeRateController.text) ?? 0.0,
        if (!_fixedCapacity) ...{
          "capacity_step": int.tryParse(_capacityStepController.text),
          "step_fee": double.tryParse(_stepFeeController.text),
        },
        "max_capacity": int.tryParse(_maxCapacityController.text),
        "max_duration": int.tryParse(_maxDurationController.text),
      },
      items: _packageItems.map((item) => PackageItemInput(
            serviceId: item['service_id'],
            quantity: item['quantity'],
          )).toList(),
    );

    try {
      final success = await _apiService.createPackage(packageRequest.toJson());
      if (success && mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) AppAlerts.showPopup(context, 'Failed to create package: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Package', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController, 
                label: 'Package Name*', 
                hint: 'e.g. Premium Wedding Package',
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              CustomTextField(
                controller: _descController, 
                label: 'Description*', 
                maxLines: 3,
                hint: 'Detailed description of what the package includes',
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: CustomTextField(
                    controller: _basePriceController, 
                    label: 'Base Price*', 
                    hint: 'Included hrs price',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(
                    controller: _capacityController, 
                    label: 'Base Capacity*', 
                    hint: 'Guests included',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  )),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("Booking Management (Optional)", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(
                    controller: _inventoryController, 
                    label: 'Inventory Count', 
                    hint: 'Min: 1', 
                    keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(
                    controller: _noticeController, 
                    label: 'Min Notice (Hrs)', 
                    hint: 'Min: 0', 
                    keyboardType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(
                    controller: _durationController, 
                    label: 'Min Duration (Hrs)', 
                    hint: 'Min: 1', 
                    keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(
                    controller: _bufferController, 
                    label: 'Buffer (Mins)', 
                    hint: 'e.g. 30', 
                    keyboardType: TextInputType.number)),
                ],
              ),

              SwitchListTile(
                title: const Text('Fixed Capacity', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('True = strict limit. False = variable with surcharges'),
                value: _fixedCapacity,
                activeColor: AppColor.primary,
                onChanged: (val) => setState(() => _fixedCapacity = val),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text("Pricing Configuration", 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ),
              if (!_fixedCapacity) ...[
                Row(
                  children: [
                    Expanded(child: CustomTextField(
                      controller: _capacityStepController, 
                      label: 'Capacity Step*', 
                      hint: 'Guests per pricing step',
                      validator: (v) => !_fixedCapacity && v!.isEmpty ? 'Required for variable' : null,
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextField(
                      controller: _stepFeeController, 
                      label: 'Step Fee*', 
                      hint: 'Flat fee per step',
                      validator: (v) => !_fixedCapacity && v!.isEmpty ? 'Required for variable' : null,
                    )),
                  ],
                ),
              ],
              CustomTextField(
                controller: _overtimeRateController, 
                label: 'Overtime Hourly Rate*', 
                hint: 'Rate for time beyond included hrs',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(child: CustomTextField(controller: _maxCapacityController, label: 'Max Capacity', hint: 'Optional limit')),
                  const SizedBox(width: 16),
                  Expanded(child: CustomTextField(controller: _maxDurationController, label: 'Max Duration (Hrs)', hint: 'Optional limit')),
                ],
              ),

              const SizedBox(height: 16),
              const Text("Categories (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
              _buildCategorySelector(),

              const SizedBox(height: 24),
              AvailableAreasSection(
                areaTree: _areaTree,
                availableAreaPaths: _availableAreaPaths,
                onUpdate: (paths) => setState(() => _availableAreaPaths = paths),
              ),

              const SizedBox(height: 24),
              const Text("Package Items (Optional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                onRemove: (index) => setState(() => _packageItems.removeAt(index)),
              ),
              
              SwitchListTile(
                title: const Text('Active Status'),
                value: _isActive,
                activeColor: AppColor.primary,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _categoriesPagination.dataNotifier,
      builder: (context, categories, _) => CategorySelector(
        categories: categories,
        selectedIds: _selectedCategoryIds,
        onSelected: (id, isSelected) {
          setState(() {
            isSelected ? _selectedCategoryIds.add(id) : _selectedCategoryIds.remove(id);
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPackage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text('Create Package', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}