import 'package:eventak/service-provider-UI/features/show_package/widgets/edit_package_widgets.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/pagination_handler.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_area_selector.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_widgets.dart'; 
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
  final AddServiceRepo _repo = AddServiceRepo();

  
  late TextEditingController _nameController, _descController, _basePriceController, _capacityController;
  late TextEditingController _inventoryController, _noticeController, _durationController, _bufferController;
  late TextEditingController _overtimeRateController, _capacityStepController, _stepFeeController, _maxCapacityController, _maxDurationController, _includedHoursController;

  bool _isLoading = false;
  late bool _fixedCapacity;
  late List<PackageItem> _currentItems;
  late List<int> _selectedCategoryIds;

  List<Map<String, dynamic>> _areaTree = [];
  List<List<int?>> _availableAreaPaths = [];

  late PaginationHandler<Map<String, dynamic>> _categoriesPagination;
  final ValueNotifier<List<Map<String, dynamic>>> _availableServicesNotifier = ValueNotifier([]);
  bool _isFetchingServices = false;
  bool _hasMoreServices = true;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _fetchInitialData();
  }

  void _initControllers() {
    final p = widget.package;
    _nameController = TextEditingController(text: p.name);
    _descController = TextEditingController(text: p.description);
    _basePriceController = TextEditingController(text: p.price.toString());
    _capacityController = TextEditingController(text: p.capacity.toString());

    _inventoryController = TextEditingController(text: p.inventoryCount?.toString() ?? "");
    _noticeController = TextEditingController(text: p.minimumNoticeHours?.toString() ?? "");
    _durationController = TextEditingController(text: p.minimumDurationHours?.toString() ?? "");
    _bufferController = TextEditingController(text: p.bufferTimeMinutes?.toString() ?? "");

    final conf = p.pricingConfig;
    _overtimeRateController = TextEditingController(text: conf?.overtimeRate.toString() ?? "");
    _capacityStepController = TextEditingController(text: conf?.capacityStep?.toString() ?? "");
    _stepFeeController = TextEditingController(text: conf?.stepFee?.toString() ?? "");
    _maxCapacityController = TextEditingController(text: conf?.maxCapacity?.toString() ?? "");
    _maxDurationController = TextEditingController(text: conf?.maxDuration?.toString() ?? "");

    _fixedCapacity = p.fixedCapacity;
    _currentItems = List.from(p.items);
    _selectedCategoryIds = List.from(p.categoryIds);

    _availableServicesNotifier.value = widget.availableServices;
    if (widget.availableServices.length < 15) _hasMoreServices = false;

    _categoriesPagination = PaginationHandler(
      fetchData: (page) => _api.fetchListData('service-categories', page),
    );
    _categoriesPagination.fetchNextPage();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final areas = await _repo.getAreasTree();
      setState(() {
        _areaTree = List<Map<String, dynamic>>.from(areas);
        _availableAreaPaths = widget.package.availableAreas.map((areaObj) {
          return _calculateAreaPath(areaObj['id']);
        }).toList();

        if (_availableAreaPaths.isEmpty) _availableAreaPaths.add([]);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<int?> _calculateAreaPath(int targetId) {
    List<int?> path = [];
    bool find(List<Map<String, dynamic>> items, int id) {
      for (var item in items) {
        path.add(item['id']);
        if (item['id'] == id) return true;
        if (item['children'] != null && find(List<Map<String, dynamic>>.from(item['children']), id)) return true;
        path.removeLast();
      }
      return false;
    }
    find(_areaTree, targetId);
    return path;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final List<int> availabilityIds = _availableAreaPaths
          .where((p) => p.isNotEmpty)
          .map((p) => p.last!)
          .toList();

      final updateModel = PackageUpdateRequest(
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
          "overtime_rate": double.tryParse(_overtimeRateController.text),
          if (!_fixedCapacity) ...{
            "capacity_step": int.tryParse(_capacityStepController.text),
            "step_fee": double.tryParse(_stepFeeController.text),
          },
          "max_capacity": int.tryParse(_maxCapacityController.text),
          "max_duration": int.tryParse(_maxDurationController.text),
        },
      );

      await _api.updatePackage(widget.package.id, updateModel.toJson());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        title: const Text("Edit Package", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading && _areaTree.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  EditSectionCard(
                    child: Column(
                      children: [
                        CustomTextField(controller: _nameController, label: 'Package Name*'),
                        CustomTextField(controller: _descController, label: 'Description*', maxLines: 3),
                        Row(
                          children: [
                            Expanded(child: CustomTextField(controller: _basePriceController, label: 'Base Price*', keyboardType: TextInputType.number)),
                            const SizedBox(width: 16),
                            Expanded(child: CustomTextField(controller: _capacityController, label: 'Base Capacity*', keyboardType: TextInputType.number)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  EditSectionCard(
                    title: "Booking Management",
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: CustomTextField(controller: _inventoryController, label: 'Inventory', hint: 'Min: 1')),
                            const SizedBox(width: 16),
                            Expanded(child: CustomTextField(controller: _noticeController, label: 'Min Notice (Hrs)', hint: 'Min: 0')),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: CustomTextField(controller: _durationController, label: 'Min Dur (Hrs)', hint: 'Min: 1')),
                            const SizedBox(width: 16),
                            Expanded(child: CustomTextField(controller: _bufferController, label: 'Buffer (Mins)', hint: 'e.g. 30')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  EditSectionCard(
                    title: "Pricing & Capacity",
                    titleColor: AppColor.primary,
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Fixed Capacity', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(_fixedCapacity ? "Strict limit" : "Variable surcharges enabled", style: const TextStyle(fontSize: 12)),
                          value: _fixedCapacity,
                          activeColor: AppColor.primary,
                          onChanged: (val) => setState(() => _fixedCapacity = val),
                        ),
                        const Divider(height: 32),
                        PricingConfigFields(
                          isFixed: _fixedCapacity,
                          overtimeRate: _overtimeRateController,
                          capacityStep: _capacityStepController,
                          stepFee: _stepFeeController,
                          maxCapacity: _maxCapacityController,
                          maxDuration: _maxDurationController,
                        ),
                      ],
                    ),
                  ),

                  EditSectionCard(
                    title: "Categories",
                    child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _categoriesPagination.dataNotifier,
                      builder: (context, categories, _) => CategorySelector(
                        categories: categories,
                        selectedIds: _selectedCategoryIds,
                        onSelected: (id, selected) => setState(() {
                          selected ? _selectedCategoryIds.add(id) : _selectedCategoryIds.remove(id);
                        }),
                      ),
                    ),
                  ),

                  AvailableAreasSection(
                    areaTree: _areaTree,
                    availableAreaPaths: _availableAreaPaths,
                    onUpdate: (paths) => setState(() => _availableAreaPaths = paths),
                  ),

                  const SizedBox(height: 24),

                  _buildIncludedServicesSection(),

                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildIncludedServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Included Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(onPressed: _showAddServiceDialog, icon: const Icon(Icons.add), label: const Text("Add")),
          ],
        ),
        ..._currentItems.map((item) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            title: Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text("Quantity: ${item.quantity}"),
            trailing: IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showQuantityDialog(item)),
          ),
        )),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : const Text("Update Package", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _silentRefresh() async {
    try {
      final updated = await _api.getPackageDetails(widget.package.id);
      if (mounted) setState(() => _currentItems = List.from(updated.items));
    } catch (e) { debugPrint(e.toString()); }
  }

  void _showAddServiceDialog() {
    showDialog(context: context, builder: (ctx) => AddServiceDialog(
      servicesNotifier: _availableServicesNotifier,
      onLoadMore: () {},
      hasMore: _hasMoreServices,
      isLoadingMore: _isFetchingServices,
      onAdd: (id, q) async {
        await _api.addPackageItem(widget.package.id, id, q);
        await _silentRefresh();
      },
    ));
  }

  void _showQuantityDialog(PackageItem item) {
    showDialog(context: context, builder: (ctx) => UpdateQuantityDialog(
      initialQuantity: item.quantity,
      onUpdate: (q) async {
        await _api.updatePackageItem(widget.package.id, item.id, q);
        await _silentRefresh();
      },
    ));
  }

  @override
  void dispose() {
    _nameController.dispose(); _descController.dispose(); _basePriceController.dispose();
    _capacityController.dispose(); _inventoryController.dispose(); _noticeController.dispose();
    _durationController.dispose(); _bufferController.dispose(); _overtimeRateController.dispose();
    _capacityStepController.dispose(); _stepFeeController.dispose(); _maxCapacityController.dispose();
    _maxDurationController.dispose(); _includedHoursController.dispose(); _availableServicesNotifier.dispose(); _categoriesPagination.dispose();
    super.dispose();
  }
}