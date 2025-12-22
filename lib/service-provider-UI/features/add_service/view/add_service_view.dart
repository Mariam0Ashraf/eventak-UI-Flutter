import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final AddServiceRepo _repo = AddServiceRepo();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _submitService() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final serviceData = {
      "category_id": _selectedCategoryId,
      "name": _nameController.text.trim(),
      "description": _descController.text.trim(),
      "base_price": double.tryParse(_priceController.text) ?? 0.0,
      "price_unit": _selectedPriceUnit,
      "location": _locationController.text.trim(),
      "is_active": _isActive,
    };

    try {
      await _repo.createService(serviceData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service added successfully!'),
            backgroundColor: Colors.green,
          ),
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
        title: const Text(
          'Add New Service',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
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
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    ),

                    CustomTextField(
                      controller: _nameController,
                      label: 'Service Name',
                      hint: 'e.g. Wedding Photography',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),

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
                              if (double.tryParse(v) == null) return 'Invalid #';
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
                            items: _priceUnits.map((u) => DropdownMenuItem(
                              value: u, 
                              child: Text(u)
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedPriceUnit = val!),
                          ),
                        ),
                      ],
                    ),

                    CustomTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'e.g. Cairo, Egypt',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: const Text(
                          'Active Status',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text(
                          _isActive ? 'Visible to customers' : 'Hidden from search',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        value: _isActive,
                        activeThumbColor: AppColor.primary,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
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
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24, 
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                              )
                            : const Text(
                                'Create Service', 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
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