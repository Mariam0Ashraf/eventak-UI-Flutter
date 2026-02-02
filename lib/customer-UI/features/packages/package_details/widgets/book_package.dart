import 'package:eventak/customer-UI/features/cart/data/cart_provider.dart';
import 'package:eventak/service-provider-UI/features/add_service/data/add_service_repo.dart';
import 'package:eventak/service-provider-UI/features/add_service/widgets/form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:provider/provider.dart';
import '../data/package_model.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import '../data/package_details_service.dart';

class BookPackageSheet extends StatefulWidget {
  final PackageData package;
  const BookPackageSheet({super.key, required this.package});

  @override
  State<BookPackageSheet> createState() => _BookPackageSheetState();
}

class _BookPackageSheetState extends State<BookPackageSheet> {
  final _api = PackageDetailsService();
  final AddServiceRepo _areaRepo = AddServiceRepo();
  final _notesController = TextEditingController();
  final _capacityController = TextEditingController(); 
  final _formKey = GlobalKey<FormState>();

  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int _capacity = 1; // Starts at 1
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _areaTree = [];
  List<int> _selectedAreaIds = [];
  bool _isAreaLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAreaData();
    _capacity = 1; 
    _capacityController.text = _capacity.toString();
  }

  Future<void> _fetchAreaData() async {
    try {
      final tree = await _areaRepo.getAreasTree();
      setState(() {
        _areaTree = tree;
        _isAreaLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isAreaLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return "Not selected";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildAreaDropdowns() {
    if (_isAreaLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_areaTree.isEmpty) return const SizedBox.shrink();

    List<Widget> dropdownWidgets = [];
    List<Map<String, dynamic>> currentLevelItems = _areaTree;

    for (int i = 0; i <= _selectedAreaIds.length; i++) {
      if (currentLevelItems.isEmpty) break;

      int? selectedIdForThisLevel = i < _selectedAreaIds.length ? _selectedAreaIds[i] : null;
      String typeName = currentLevelItems.first['type'] ?? 'Area';

      dropdownWidgets.add(
        CustomDropdownField<int>(
          label: "${typeName[0].toUpperCase() + typeName.substring(1)} ${i > 0 ? '(Optional)' : '(Required)'}",
          value: selectedIdForThisLevel,
          hintText: 'Select $typeName',
          validator: i == 0 ? (val) => val == null ? 'Please select a $typeName' : null : null,
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
          var selectedNode = currentLevelItems.firstWhere((item) => item['id'] == selectedIdForThisLevel);
          currentLevelItems = List<Map<String, dynamic>>.from(selectedNode['children'] ?? []);
        } catch (e) {
          currentLevelItems = [];
        }
      } else {
        break;
      }
    }
    return Column(children: dropdownWidgets);
  }

  Future<void> _handleAddToCart() async {
    if (!_formKey.currentState!.validate()) return;

    if (_date == null) {
      AppAlerts.showPopup(context, 'Please select a date', isError: true);
      return;
    }

    if (_selectedAreaIds.isEmpty && _areaTree.isNotEmpty) {
      AppAlerts.showPopup(context, 'Please select an area', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final String formattedDate =
          "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}";

      final int targetAreaId = _selectedAreaIds.last;

      await _api.addToCart(
        packageId: widget.package.id,
        eventDate: formattedDate,
        startTime: _startTime != null ? _formatTime(_startTime) : null,
        endTime: _endTime != null ? _formatTime(_endTime) : null,
        capacity: !widget.package.fixedCapacity ? _capacity : null,
        notes: _notesController.text.trim(),
        areaId: targetAreaId, 
      );

      if (mounted) {
        Navigator.pop(context);
        context.read<CartProvider>().refreshCart();
        AppAlerts.showPopup(context, 'Added to cart successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showPopup(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Book ${widget.package.name}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.blueFont)),
              const SizedBox(height: 16),

              const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildPickerContainer(
                Icons.calendar_today,
                _date == null ? 'Choose Date' : "${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}",
                () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),

              const SizedBox(height: 16),
              const Text('Available Area', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildAreaDropdowns(),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerCol('Start Time', _startTime, (t) => setState(() => _startTime = t)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePickerCol('End Time (Opt)', _endTime, (t) => setState(() => _endTime = t)),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                'Capacity / Guests ${widget.package.fixedCapacity ? "(Fixed)" : "(Required)"}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (widget.package.fixedCapacity)
                Text('${widget.package.capacity} Persons (Included in Package)',
                    style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic))
              else
                _buildCapacityCounter(),

              const SizedBox(height: 16),
              const Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Any special requests?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerCol(String label, TimeOfDay? time, Function(TimeOfDay) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        _buildPickerContainer(
          Icons.access_time,
          _formatTime(time),
          () async {
            final t = await showTimePicker(context: context, initialTime: time ?? TimeOfDay.now());
            if (t != null) onPick(t);
          },
        ),
      ],
    );
  }

  Widget _buildPickerContainer(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [Icon(icon, size: 20, color: AppColor.blueFont), const SizedBox(width: 10), Text(text)]),
      ),
    );
  }

  Widget _buildCapacityCounter() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
          onPressed: _capacity > 1
              ? () {
                  setState(() {
                    _capacity--;
                    _capacityController.text = _capacity.toString();
                  });
                }
              : null,
        ),
        
        Container(
          width: 80,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: TextFormField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              final int? parsed = int.tryParse(value);
              if (parsed != null && parsed >= 1) {
                setState(() => _capacity = parsed);
              }
            },
            onFieldSubmitted: (value) {
              if (value.isEmpty || int.tryParse(value) == null || int.parse(value) < 1) {
                setState(() {
                  _capacity = 1;
                  _capacityController.text = "1";
                });
              }
            },
          ),
        ),

        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
          onPressed: () {
            setState(() {
              _capacity++;
              _capacityController.text = _capacity.toString();
            });
          },
        ),
      ],
    );
  }
}