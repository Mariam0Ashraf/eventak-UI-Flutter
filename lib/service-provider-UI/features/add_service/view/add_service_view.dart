import 'dart:io';
import 'package:eventak/service-provider-UI/features/policy/view/create_policy_view.dart';
import 'package:eventak/service-provider-UI/features/policy/widgets/policy_prompt_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final AddServiceRepo _repo = AddServiceRepo();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _inventoryController = TextEditingController();

  final TextEditingController _minNoticeController = TextEditingController();
  final TextEditingController _minDurationController = TextEditingController();
  final TextEditingController _bufferTimeController = TextEditingController();

  final TextEditingController _capacityStepController = TextEditingController();
  final TextEditingController _stepFeeController = TextEditingController();
  final TextEditingController _maxCapacityController = TextEditingController();
  final TextEditingController _minCapacityController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _serviceTypes = [];
  List<Map<String, dynamic>> _areaTree = [];
  List<int?> _selectedAreaIds = [];

  List<int> _selectedCategoryIds = [];
  List<List<int?>> _availableAreaPaths = [[]];

  int? _selectedServiceTypeId;

  String _selectedPriceUnit = 'hourly';
  final List<String> _priceUnits = ['hourly', 'daily'];
  bool _isFixedCapacity = true;
  bool _isActive = true;

  XFile? _pickedThumbnail;
  Uint8List? _thumbnailBytes;
  List<XFile> _pickedGallery = [];
  List<Uint8List> _galleryBytes = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    _inventoryController.dispose();
    _minNoticeController.dispose();
    _minDurationController.dispose();
    _bufferTimeController.dispose();
    _capacityStepController.dispose();
    _stepFeeController.dispose();
    _maxCapacityController.dispose();
    _minCapacityController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _repo.getServiceCategories(),
        _repo.getServiceTypes(),
        _repo.getAreasTree(),
      ]);
      setState(() {
        _categories = results[0];
        _serviceTypes = results[1];
        _areaTree = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickThumbnail() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedThumbnail = image;
        _thumbnailBytes = bytes;
      });
    }
  }

  Future<void> _pickGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      List<Uint8List> newBytes = [];
      for (var img in images) {
        newBytes.add(await img.readAsBytes());
      }
      setState(() {
        _pickedGallery = images;
        _galleryBytes = newBytes;
      });
    }
  }

  Widget _buildAreaDropdowns() {
    if (_areaTree.isEmpty) return const SizedBox.shrink();
    List<Widget> dropdownWidgets = [];
    List<Map<String, dynamic>> currentLevelItems = _areaTree;

    for (int i = 0; i <= _selectedAreaIds.length; i++) {
      if (currentLevelItems.isEmpty) break;
      int? selectedIdForThisLevel = i < _selectedAreaIds.length ? _selectedAreaIds[i] : null;
      String typeName = currentLevelItems.first['type'] ?? 'Area';

      dropdownWidgets.add(
        CustomDropdownField<int>(
          label: "${typeName[0].toUpperCase() + typeName.substring(1)} ${i > 0 ? '(Optional)' : ''}",
          value: selectedIdForThisLevel,
          hintText: 'Select $typeName',
          validator: i == 0 ? (val) => val == null ? 'Country is required' : null : null,
          items: currentLevelItems.map((area) {
            return DropdownMenuItem<int>(
              value: area['id'],
              child: Text(area['name']),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              if (i < _selectedAreaIds.length) {
                _selectedAreaIds = _selectedAreaIds.sublist(0, i);
              }
              if (val != null) _selectedAreaIds.add(val);
            });
          },
        ),
      );

      if (selectedIdForThisLevel != null) {
        try {
          var selectedNode = currentLevelItems.firstWhere(
            (item) => item['id'] == selectedIdForThisLevel,
          );
          currentLevelItems = List<Map<String, dynamic>>.from(
            selectedNode['children'] ?? [],
          );
        } catch (e) {
          currentLevelItems = [];
        }
      } else {
        break;
      }
    }
    return Column(children: dropdownWidgets);
  }

  Widget _buildAvailableAreas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Available Areas",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
                            onPressed: () => setState(
                              () => _availableAreaPaths.removeAt(index),
                            ),
                          ),
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
          items: currentItems.map((area) {
            return DropdownMenuItem<int>(
              value: area['id'],
              child: Text(area['name']),
            );
          }).toList(),
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
          var node = currentItems.firstWhere(
            (item) => item['id'] == selectedId,
          );
          currentItems = List<Map<String, dynamic>>.from(
            node['children'] ?? [],
          );
        } catch (e) {
          currentItems = [];
        }
      } else {
        break;
      }
    }
    return Column(children: widgets);
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedThumbnail == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a thumbnail')));
      return;
    }

    if (_selectedAreaIds.isEmpty || _selectedAreaIds[0] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least a country')));
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one category')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> dataMap = {
        "service_type_id": _selectedServiceTypeId,
        "area_id": _selectedAreaIds.where((id) => id != null).last,
        "name": _nameController.text.trim(),
        "description": _descController.text.trim(),
        "base_price": _priceController.text.trim(),
        "price_unit": _selectedPriceUnit,
        "fixed_capacity": _isFixedCapacity ? 1 : 0,
        "inventory_count": _inventoryController.text.isEmpty ? "1" : _inventoryController.text.trim(),
        "location": _locationController.text.trim(),
        "capacity": _capacityController.text.trim(),
        "address": _addressController.text.trim(),
        "is_active": _isActive ? 1 : 0,
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
      formData.files.add(MapEntry("thumbnail", MultipartFile.fromBytes(_thumbnailBytes!, filename: _pickedThumbnail!.name)));
      for (int i = 0; i < _galleryBytes.length; i++) {
        formData.files.add(MapEntry("gallery[]", MultipartFile.fromBytes(_galleryBytes[i], filename: _pickedGallery[i].name)));
      }

      // 1. Capture full response map
      final response = await _repo.createService(formData);

      if (mounted) {
        setState(() => _isLoading = false);
        final String serviceName = _nameController.text.trim();
        final int serviceId = response['data']['id'];

        // 2. Await the dialog decision result
        final bool? wantCustomPolicy = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => PolicyPromptDialog(
            itemName: serviceName,
            itemId: serviceId,
            isPackage: false,
          ),
        );

        // 3. Perform navigation AFTER dialog returns its result
        if (mounted) {
          if (wantCustomPolicy == true) {
            // Swap screens so they don't go back to the half-filled form
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreatePolicyView(
                  itemId: serviceId,
                  isPackage: false,
                ),
              ),
            );
          } else {
            // Use global selected: simply go back to the service list
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Service', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdownField<int>(
                      label: 'Service Type',
                      value: _selectedServiceTypeId,
                      items: _serviceTypes
                          .map((t) => DropdownMenuItem(
                                value: t['id'] as int,
                                child: Text(t['name']),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedServiceTypeId = val),
                    ),
                    const Text(
                      "Categories",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          _selectedCategoryIds.isEmpty
                              ? "Select Categories"
                              : "${_selectedCategoryIds.length} Selected",
                        ),
                        children: _categories.map((cat) {
                          return CheckboxListTile(
                            title: Text(cat['name'] ?? ''),
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
                    CustomTextField(
                      controller: _nameController,
                      label: 'Service Name',
                      hint: 'e.g. Photography',
                    ),
                    CustomTextField(
                      controller: _descController,
                      label: 'Description',
                      hint: 'Details...',
                      maxLines: 3,
                    ),
                    _buildAreaDropdowns(),
                    _buildAvailableAreas(),
                    CustomTextField(
                      controller: _minNoticeController,
                      label: 'Minimum Notice (Hours)',
                      hint: 'optional',
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    CustomTextField(
                      controller: _minDurationController,
                      label: 'Minimum Duration (Hours)',
                      hint: 'optional',
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    CustomTextField(
                      controller: _bufferTimeController,
                      label: 'Buffer Time (Minutes)',
                      hint: 'optional',
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    const Text("Service Image ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickThumbnail,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _thumbnailBytes == null
                            ? const Icon(Icons.add_a_photo, color: Colors.grey)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(_thumbnailBytes!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Gallery Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickGallery,
                      icon: const Icon(Icons.photo_library),
                      label: Text("Select Gallery (${_pickedGallery.length})"),
                    ),
                    if (_galleryBytes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _galleryBytes.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(_galleryBytes[index], width: 80, height: 80, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _galleryBytes.removeAt(index);
                                        _pickedGallery.removeAt(index);
                                      }),
                                      child: Container(
                                        color: Colors.black54,
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: _priceController,
                            label: 'Base Price',
                            hint: 'The starting cost.',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CustomDropdownField<String>(
                            label: 'Price Unit',
                            value: _selectedPriceUnit,
                            items: _priceUnits
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u[0].toUpperCase() + u.substring(1)),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedPriceUnit = val!),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Fixed Capacity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(_isFixedCapacity ? "Standard pricing" : "Step pricing required"),
                      value: _isFixedCapacity,
                      activeColor: AppColor.primary,
                      onChanged: (val) => setState(() => _isFixedCapacity = val),
                    ),
                    if (!_isFixedCapacity) ...[
                      const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),
                      Text("Pricing Configuration", style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary)),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _capacityStepController,
                        label: 'Capacity Step',
                        hint: 'e.g. 10',
                        keyboardType: TextInputType.number,
                      ),
                      CustomTextField(
                        controller: _stepFeeController,
                        label: 'Step Fee',
                        hint: 'Cost per block',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _maxCapacityController,
                              label: 'Max Capacity',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _minCapacityController,
                              label: 'Min Capacity',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: _inventoryController,
                      label: 'Inventory Count',
                      hint: 'optional',
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Full Address',
                      hint: 'optional',
                      validator: (v) => null,
                    ),
                    CustomTextField(
                      controller: _locationController,
                      label: 'City/Location',
                    ),
                    CustomTextField(
                      controller: _capacityController,
                      label: 'Capacity',
                      hint: 'optional',
                      keyboardType: TextInputType.number,
                      validator: (v) => null,
                    ),
                    SwitchListTile(
                      title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      value: _isActive,
                      activeColor: AppColor.primary,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Create Service', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}