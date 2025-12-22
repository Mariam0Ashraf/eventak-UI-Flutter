import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/data/add_package_service.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_items_list.dart';
import 'package:eventak/service-provider-UI/features/add_pacakge/wedgits/package_item_form.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';

class AddPackageView extends StatefulWidget {
  final List<Map<String, dynamic>> services;

  const AddPackageView({
    super.key,
    required this.services,
  });

  @override
  State<AddPackageView> createState() => _AddPackageViewState();
}


class _AddPackageViewState extends State<AddPackageView> {
  final _formKey = GlobalKey<FormState>();
  final AddPackageService _service = AddPackageService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  // ✅ NEW – cart state
  final List<Map<String, dynamic>> _packageItems = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitPackage() async {
    if (!_formKey.currentState!.validate()) return;

    if (_packageItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item')),
      );
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
          itemDescription: item['item_description'],
          quantity: item['quantity'],
          priceAdjustment: item['price_adjustment'],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Package created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Package',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
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
              CustomTextField(
                controller: _nameController,
                label: 'Package Name',
                hint: 'e.g. Gold Wedding Package',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Describe what this package includes...',
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              
              const SizedBox(height: 24),

              PackageItemForm(
                services: widget.services, 
                onAdd: (item) {
                  setState(() => _packageItems.add(item));
                },
              ),

              const SizedBox(height: 12),

              PackageItemsList(
                items: _packageItems,
                onRemove: (index) {
                  setState(() => _packageItems.removeAt(index));
                },
              ),

              const SizedBox(height: 24),
              

              CustomTextField(
                controller: _priceController,
                label: 'Price',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
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
                    _isActive
                        ? 'Visible to customers'
                        : 'Hidden from listing',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  value: _isActive,
                  activeTrackColor: AppColor.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitPackage,
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
                          'Create Package',
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
