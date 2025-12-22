import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_api.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class EditServiceView extends StatefulWidget {
  final MyService service;

  const EditServiceView({super.key, required this.service});

  @override
  State<EditServiceView> createState() => _EditServiceViewState();
}

class _EditServiceViewState extends State<EditServiceView> {
  final _formKey = GlobalKey<FormState>();
  final AddServiceRepo _repo = AddServiceRepo();
  final MyServicesService _servicesApi = MyServicesService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;

  String _selectedPriceUnit = 'fixed';
  final List<String> _priceUnits = ['fixed', 'hour', 'person'];

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.service.name;
    _descController.text = widget.service.description ?? '';
    _priceController.text = widget.service.basePrice?.toStringAsFixed(2) ?? '';
    _locationController.text = widget.service.location ?? '';

    _selectedCategoryId = widget.service.categoryId;

    if (widget.service.priceUnit != null &&
        _priceUnits.contains(widget.service.priceUnit)) {
      _selectedPriceUnit = widget.service.priceUnit!;
    } else {
      _selectedPriceUnit = 'fixed';
    }

    _isActive = widget.service.isActive;

    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _repo.getServiceCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
      }
    }
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);

    final updatedService = MyService(
      id: widget.service.id,
      categoryId: _selectedCategoryId,
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      basePrice: double.tryParse(_priceController.text) ?? 0.0,
      priceUnit: _selectedPriceUnit,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      isActive: _isActive,
    );

    try {
      await _servicesApi.updateService(updatedService);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInitialLoading = _isLoading && _categories.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Service',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category
                    CustomDropdownField<int>(
                      label: 'Category',
                      hintText: 'Select a category',
                      value: _selectedCategoryId,
                      items: _categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'],
                          child: Text(cat['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategoryId = val),
                    ),

                    // Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Service Name',
                      hint: 'e.g. Wedding Photography',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),

                    // Description
                    CustomTextField(
                      controller: _descController,
                      label: 'Description',
                      hint: 'Describe your service details...',
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: _priceController,
                            label: 'Base Price',
                            hint: '0.00',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (double.tryParse(v) == null) {
                                return 'Invalid #';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: CustomDropdownField<String>(
                            label: 'Unit',
                            value: _selectedPriceUnit,
                            hintText: 'Unit',
                            items: _priceUnits
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedPriceUnit = val!),
                          ),
                        ),
                      ],
                    ),

                    // Location
                    CustomTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'e.g. Cairo, Egypt',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 8),

                    // Active switch
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        title: const Text(
                          'Active Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          _isActive
                              ? 'Visible to customers'
                              : 'Hidden from search',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        value: _isActive,
                        activeTrackColor: AppColor.primary,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
