import 'dart:io';
import 'package:eventak/core/constants/api_constants.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:eventak/service-provider-UI/features/show_service/widgets/edit_service_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditServiceView extends StatefulWidget {
  final MyService service;
  const EditServiceView({super.key, required this.service});

  @override
  State<EditServiceView> createState() => _EditServiceViewState();
}

class _EditServiceViewState extends State<EditServiceView> {
  final _formKey = GlobalKey<FormState>();
  final AddServiceRepo _repo = AddServiceRepo();
  final MyServicesService _serviceApi = MyServicesService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController,
      _descController,
      _priceController,
      _locationController,
      _addressController,
      _capacityController,
      _inventoryController,
      _capacityStepController,
      _stepFeeController,
      _maxCapacityController,
      _minCapacityController,
      _minNoticeController,
      _minDurationController,
      _bufferTimeController;

  bool _isLoading = false, _isFixedCapacity = true, _isActive = true;
  List<Map<String, dynamic>> _categories = [], _serviceTypes = [], _areaTree = [];
  List<int?> _selectedAreaIds = [];
  List<int> _selectedCategoryIds = [];
  List<List<int?>> _availableAreaPaths = []; 

  int? _selectedServiceTypeId;
  String _selectedPriceUnit = 'hourly';
  final List<String> _priceUnits = ['hourly', 'daily'];

  XFile? _pickedThumbnail;
  Uint8List? _thumbnailBytes;
  List<GalleryMedia> _existingGallery = [];
  List<XFile> _pickedGalleryFiles = [];
  List<Uint8List> _galleryBytes = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _fetchInitialData();
  }

  void _initControllers() {
    final s = widget.service;
    _nameController = TextEditingController(text: s.name);
    _descController = TextEditingController(text: s.description);
    _priceController = TextEditingController(text: s.basePrice?.toString());
    _locationController = TextEditingController(text: s.location);
    _addressController = TextEditingController(text: s.address);
    _capacityController = TextEditingController(text: s.capacity?.toString());
    _inventoryController = TextEditingController(text: s.inventoryCount?.toString());

    final config = s.pricingConfig;
    _capacityStepController = TextEditingController(text: config?['capacity_step']?.toString());
    _stepFeeController = TextEditingController(text: config?['step_fee']?.toString());
    _maxCapacityController = TextEditingController(text: config?['max_capacity']?.toString());
    _minCapacityController = TextEditingController(text: config?['min_capacity']?.toString());

    _minNoticeController = TextEditingController(text: s.minimumNoticeHours?.toString());
    _minDurationController = TextEditingController(text: s.minimumDurationHours?.toString());
    _bufferTimeController = TextEditingController(text: s.bufferTimeMinutes?.toString());

    _selectedCategoryIds = List<int>.from(s.categoryIds);
    _selectedServiceTypeId = s.serviceTypeId;
    _selectedPriceUnit = s.priceUnit ?? 'hourly';
    _isFixedCapacity = s.fixedCapacity;
    _isActive = s.isActive;
    _existingGallery = List<GalleryMedia>.from(s.gallery);
  }

  @override
  void dispose() {
    for (var c in [
      _nameController, _descController, _priceController, _locationController,
      _addressController, _capacityController, _inventoryController,
      _capacityStepController, _stepFeeController, _maxCapacityController,
      _minCapacityController, _minNoticeController, _minDurationController, _bufferTimeController
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([_repo.getServiceCategories(), _repo.getServiceTypes(), _repo.getAreasTree()]);
      setState(() {
        _categories = List<Map<String, dynamic>>.from(results[0]);
        _serviceTypes = List<Map<String, dynamic>>.from(results[1]);
        _areaTree = List<Map<String, dynamic>>.from(results[2]);

        
        if (widget.service.areaId != null) {
          _selectedAreaIds = _calculateAreaPath(widget.service.areaId!);
        }

   
        _availableAreaPaths = [];
        for (var areaId in widget.service.availableAreaIds) {
          _availableAreaPaths.add(_calculateAreaPath(areaId));
        }
        if (_availableAreaPaths.isEmpty) _availableAreaPaths.add([]);

        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<int> _calculateAreaPath(int targetId) {
    List<int> path = [];
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

  Future<void> _deleteExistingImage(int mediaId) async {
    try {
      setState(() => _isLoading = true);
      await _serviceApi.deleteGalleryImage(widget.service.id, mediaId);
      setState(() {
        _existingGallery.removeWhere((item) => item.id == mediaId);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
        } catch (e) { currentItems = []; }
      } else { break; }
    }
    return Column(children: widgets);
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAreaIds.isEmpty || _selectedAreaIds[0] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least a country')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token')?.replaceAll('"', '');
      final Map<String, dynamic> dataMap = {
        "_method": "PUT",
        "service_type_id": _selectedServiceTypeId,
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "base_price": _priceController.text.trim(),
        "price_unit": _selectedPriceUnit,
        "fixed_capacity": _isFixedCapacity ? 1 : 0,
        "inventory_count": _inventoryController.text.trim(),
        "capacity": _capacityController.text.trim(),
        "address": _addressController.text.trim(),
        "location": _locationController.text.trim(),
        "is_active": _isActive ? 1 : 0,
        "area_id": _selectedAreaIds.where((id) => id != null).last,
        "minimum_notice_hours": _minNoticeController.text.trim(),
        "minimum_duration_hours": _minDurationController.text.trim(),
        "buffer_time_minutes": _bufferTimeController.text.trim(),
      };

      for (int i = 0; i < _selectedCategoryIds.length; i++) {
        dataMap["category_ids[$i]"] = _selectedCategoryIds[i];
      }

      for (int i = 0; i < _availableAreaPaths.length; i++) {
        if (_availableAreaPaths[i].isNotEmpty) {
          dataMap["available_area_ids[$i]"] = _availableAreaPaths[i].last;
        }
      }

      if (!_isFixedCapacity) {
        dataMap["pricing_config[capacity_step]"] = _capacityStepController.text.trim();
        dataMap["pricing_config[step_fee]"] = _stepFeeController.text.trim();
        dataMap["pricing_config[max_capacity]"] = _maxCapacityController.text.trim();
        dataMap["pricing_config[min_capacity]"] = _minCapacityController.text.trim();
      }

      final formData = FormData.fromMap(dataMap);
      if (_thumbnailBytes != null) {
        formData.files.add(MapEntry("thumbnail", MultipartFile.fromBytes(_thumbnailBytes!, filename: _pickedThumbnail!.name)));
      }
      for (int i = 0; i < _galleryBytes.length; i++) {
        formData.files.add(MapEntry("gallery[]", MultipartFile.fromBytes(_galleryBytes[i], filename: _pickedGalleryFiles[i].name)));
      }

      await Dio().post('${ApiConstants.baseUrl}/services/${widget.service.id}',
          data: formData, options: Options(headers: {"Authorization": "Bearer $token", "Accept": "application/json"}));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Edit Service', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      backgroundColor: Colors.white,
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    EditServiceGallerySection(
                        thumbnailBytes: _thumbnailBytes,
                        existingThumbnailUrl: widget.service.image,
                        existingGallery: _existingGallery,
                        newGalleryBytes: _galleryBytes,
                        onPickThumbnail: () async {
                          final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            final bytes = await image.readAsBytes();
                            setState(() {
                              _pickedThumbnail = image;
                              _thumbnailBytes = bytes;
                            });
                          }
                        },
                        onPickGallery: () async {
                          final List<XFile> images = await _picker.pickMultiImage();
                          if (images.isNotEmpty) {
                            for (var img in images) {
                              final bytes = await img.readAsBytes();
                              setState(() {
                                _pickedGalleryFiles.add(img);
                                _galleryBytes.add(bytes);
                              });
                            }
                          }
                        },
                        onRemoveExisting: (mediaId) => _deleteExistingImage(mediaId),
                        onRemoveNew: (index) => setState(() {
                              _pickedGalleryFiles.removeAt(index);
                              _galleryBytes.removeAt(index);
                            })),
                    const SizedBox(height: 20),
                    CustomDropdownField<int>(
                        label: 'Service Type',
                        value: _selectedServiceTypeId,
                        items: _serviceTypes.map((t) => DropdownMenuItem(value: t['id'] as int, child: Text(t['name']))).toList(),
                        onChanged: (val) => setState(() => _selectedServiceTypeId = val)),
                    const Text("Categories", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300)),
                      child: ExpansionTile(
                        title: Text(_selectedCategoryIds.isEmpty ? "Select Categories" : "${_selectedCategoryIds.length} Selected"),
                        children: _categories.map((cat) {
                          return CheckboxListTile(
                            title: Text(cat['name'] ?? ''),
                            activeColor: AppColor.primary,
                            value: _selectedCategoryIds.contains(cat['id']),
                            onChanged: (bool? checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedCategoryIds.add(cat['id']);
                                } else {
                                  _selectedCategoryIds.remove(cat['id']);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(controller: _nameController, label: 'Service Name'),
                    CustomTextField(controller: _descController, label: 'Description', maxLines: 3),
                    EditServiceAreaDropdowns(
                        areaTree: _areaTree,
                        selectedAreaIds: _selectedAreaIds,
                        onAreaChanged: (newPath) => setState(() => _selectedAreaIds = newPath)),
                    const Text("Available Areas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ..._availableAreaPaths.asMap().entries.map((entry) => Card(
                          margin: const EdgeInsets.only(top: 8),
                          child: Padding(padding: const EdgeInsets.all(8.0), child: _buildAvailableAreaDropdowns(entry.key)),
                        )),
                    TextButton.icon(
                        onPressed: () => setState(() => _availableAreaPaths.add([])),
                        icon: const Icon(Icons.add),
                        label: const Text("Add Another Area")),
                    const SizedBox(height: 20),
                    CustomTextField(
                        controller: _minNoticeController,
                        label: 'Min Notice (Hours)',
                        hint: 'optional',
                        keyboardType: TextInputType.number,
                        validator: (v) => null),
                    CustomTextField(
                        controller: _minDurationController,
                        label: 'Min Duration (Hours)',
                        hint: 'optional',
                        keyboardType: TextInputType.number,
                        validator: (v) => null),
                    CustomTextField(
                        controller: _bufferTimeController,
                        label: 'Buffer Time (Minutes)',
                        hint: 'optional',
                        keyboardType: TextInputType.number,
                        validator: (v) => null),
                    Row(children: [
                      Expanded(
                          flex: 2,
                          child: CustomTextField(
                              controller: _priceController,
                              label: 'Base Price',
                              hint: 'The starting cost for this service.',
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 16),
                      Expanded(
                          flex: 2,
                          child: CustomDropdownField<String>(
                              label: 'Price Unit',
                              value: _selectedPriceUnit,
                              items: _priceUnits.map((u) => DropdownMenuItem(value: u, child: Text(u[0].toUpperCase()+ u.substring(1)))).toList(),
                              onChanged: (val) => setState(() => _selectedPriceUnit = val!))),
                    ]),
                    SwitchListTile(
                        title: const Text('Fixed Capacity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        value: _isFixedCapacity,
                        activeColor: AppColor.primary, 
                        onChanged: (val) => setState(() => _isFixedCapacity = val)),
                    if (!_isFixedCapacity) ...[
                      const Divider(),
                      Text("Pricing Configuration", style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary)),
                      const SizedBox(height: 16),
                      CustomTextField(
                          controller: _capacityStepController,
                          label: 'Capacity Step',
                          hint: "Do you charge per 1 person or per table of 10? Enter '1' for per-person pricing, or '10' to sell blocks of capacity.",
                          keyboardType: TextInputType.number),
                      CustomTextField(
                          controller: _stepFeeController,
                          label: 'Step Fee',
                          hint: 'The cost for each extra block.',
                          keyboardType: TextInputType.number),
                      Row(children: [
                        Expanded(
                            child: CustomTextField(
                                controller: _maxCapacityController,
                                label: 'Max Capacity',
                                hint: 'The absolute limit (safety/space) you can handle',
                                keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: CustomTextField(
                                controller: _minCapacityController,
                                label: 'Min Capacity',
                                hint: 'The smallest group size required to book.',
                                keyboardType: TextInputType.number)),
                      ]),
                    ],
                    CustomTextField(controller: _inventoryController, label: 'Inventory Count', keyboardType: TextInputType.number),
                    CustomTextField(controller: _addressController, label: 'Full Address (Optional)', validator: (v) => null),
                    CustomTextField(controller: _locationController, label: 'City/Location'), 
                    CustomTextField(controller: _capacityController, label: 'Capacity', keyboardType: TextInputType.number),
                    SwitchListTile(
                        title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        value: _isActive,
                        activeColor: AppColor.primary, 
                        onChanged: (val) => setState(() => _isActive = val)),
                    const SizedBox(height: 32),
                    SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitEdit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary, 
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Save Changes'))),
                  ])),
            ),
    );
  }
}