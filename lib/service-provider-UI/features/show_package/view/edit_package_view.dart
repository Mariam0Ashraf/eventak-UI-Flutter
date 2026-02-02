import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/constants/pagination_handler.dart';
import 'package:eventak/service-provider-UI/features/home/data/dashboard_service.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
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
  late TextEditingController _includedHoursController, _overtimeRateController, _maxDurationController;
  late TextEditingController _capacityStepController, _stepFeeController, _maxCapacityController;

  bool _isLoading = false;
  late bool _fixedCapacity;
  late List<PackageItem> _currentItems;
  late List<int> _selectedCategoryIds;

  List<Map<String, dynamic>> _areaTree = [];
  List<List<int?>> _availableAreaPaths = [];

  late PaginationHandler<Map<String, dynamic>> _categoriesPagination;
  final ValueNotifier<List<Map<String, dynamic>>> _availableServicesNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);
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

    final conf = p.pricingConfig;
    _includedHoursController = TextEditingController(text: conf?.includedHours.toString() ?? "");
    _overtimeRateController = TextEditingController(text: conf?.overtimeRate.toString() ?? "");
    _maxDurationController = TextEditingController(text: conf?.maxDuration?.toString() ?? "");
    _capacityStepController = TextEditingController(text: conf?.capacityStep?.toString() ?? "");
    _stepFeeController = TextEditingController(text: conf?.stepFee?.toString() ?? "");
    _maxCapacityController = TextEditingController(text: conf?.maxCapacity?.toString() ?? "");

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

  Widget _buildAvailableAreaDropdowns(int pathIndex) {
    List<int?> path = _availableAreaPaths[pathIndex];
    List<Widget> dropdowns = [];
    List<Map<String, dynamic>> currentLevelItems = _areaTree;

    for (int i = 0; i <= path.length; i++) {
      if (currentLevelItems.isEmpty) break;
      int? selectedId = i < path.length ? path[i] : null;
      String typeName = currentLevelItems.first['type'] ?? 'Area';

      dropdowns.add(
        CustomDropdownField<int>(
          label: "${typeName[0].toUpperCase() + typeName.substring(1)} ${i > 0 ? '(Optional)' : ''}",
          value: currentLevelItems.any((item) => item['id'] == selectedId) ? selectedId : null,
          hintText: 'Select $typeName',
          validator: i == 0 ? (val) => val == null ? 'Required' : null : null,
          items: currentLevelItems.map((area) => DropdownMenuItem<int>(value: area['id'], child: Text(area['name']))).toList(),
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
          var node = currentLevelItems.firstWhere((item) => item['id'] == selectedId);
          currentLevelItems = List<Map<String, dynamic>>.from(node['children'] ?? []);
        } catch (e) { currentLevelItems = []; }
      } else { break; }
    }
    return Column(children: dropdowns);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final List<int> availabilityIds = _availableAreaPaths
          .where((p) => p.isNotEmpty)
          .map((p) => p.last!)
          .toList();

      final updateData = {
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "base_price": double.tryParse(_basePriceController.text),
        "capacity": int.tryParse(_capacityController.text),
        "fixed_capacity": _fixedCapacity,
        "available_area_ids": availabilityIds,
        "category_ids": _selectedCategoryIds,
        "pricing_config": {
          if (!_fixedCapacity) ...{
            "included_hours": int.tryParse(_includedHoursController.text),
            "overtime_rate": double.tryParse(_overtimeRateController.text),
            "max_duration": int.tryParse(_maxDurationController.text),
            "capacity_step": int.tryParse(_capacityStepController.text),
            "step_fee": double.tryParse(_stepFeeController.text),
            "max_capacity": int.tryParse(_maxCapacityController.text),
          }
        },
      };

      await _api.updatePackage(widget.package.id, updateData);
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
        elevation: 0,
        backgroundColor: Colors.white, 
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading && _areaTree.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGeneralInfo(),
                  if (!_fixedCapacity) _buildPricingConfig(), 
                  _buildCategories(),
                  _buildAreasSection(),
                  _buildServicesSection(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildGeneralInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          CustomTextField(controller: _nameController, label: 'Package Name'),
          CustomTextField(controller: _descController, label: 'Description', maxLines: 3),
          Row(
            children: [
              Expanded(child: CustomTextField(controller: _basePriceController, label: 'Base Price', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: _capacityController, label: 'Capacity', keyboardType: TextInputType.number)),
            ],
          ),
          SwitchListTile(
            title: const Text('Fixed Capacity', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_fixedCapacity ? "Strict capacity limit" : "Variable capacity enabled", style: const TextStyle(fontSize: 12)),
            value: _fixedCapacity,
            activeColor: AppColor.primary,
            onChanged: (val) => setState(() => _fixedCapacity = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingConfig() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Advanced Pricing (Variable Capacity)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: CustomTextField(controller: _includedHoursController, label: 'Included Hours', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: _overtimeRateController, label: 'Overtime Rate', keyboardType: TextInputType.number)),
            ],
          ),
          CustomTextField(controller: _maxDurationController, label: 'Max Duration (Hours)', keyboardType: TextInputType.number),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(child: CustomTextField(controller: _capacityStepController, label: 'Capacity Step', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: CustomTextField(controller: _stepFeeController, label: 'Step Fee', keyboardType: TextInputType.number)),
            ],
          ),
          CustomTextField(controller: _maxCapacityController, label: 'Max Capacity', keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _categoriesPagination.dataNotifier,
        builder: (context, categories, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.map((cat) => FilterChip(
                  label: Text(cat['name'] ?? ''),
                  selected: _selectedCategoryIds.contains(cat['id']),
                  onSelected: (selected) => setState(() {
                    selected ? _selectedCategoryIds.add(cat['id']) : _selectedCategoryIds.remove(cat['id']);
                  }),
                )).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAreasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ..._availableAreaPaths.asMap().entries.map((entry) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          margin: const EdgeInsets.only(top: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Area ${entry.key + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (_availableAreaPaths.length > 1)
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => setState(() => _availableAreaPaths.removeAt(entry.key))),
                  ],
                ),
                _buildAvailableAreaDropdowns(entry.key),
              ],
            ),
          ),
        )),
        TextButton.icon(onPressed: () => setState(() => _availableAreaPaths.add([])), icon: const Icon(Icons.add), label: const Text("Add Another Area")),
      ],
    );
  }

  Widget _buildServicesSection() {
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary, 
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
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
    _capacityController.dispose(); _includedHoursController.dispose(); _overtimeRateController.dispose();
    _maxDurationController.dispose(); _capacityStepController.dispose(); _stepFeeController.dispose();
    _maxCapacityController.dispose(); _availableServicesNotifier.dispose(); _categoriesPagination.dispose();
    super.dispose();
  }
}