import 'package:eventak/customer-UI/features/event_management/tools/guests&rvsp/widgets/guest_constants.dart';
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/core/utils/app_alerts.dart';
import '../data/guest_model.dart';
import '../data/guest_service.dart';

class GuestFormDialog extends StatefulWidget {
  final int eventId;
  final GuestItem? guest; 
  final VoidCallback onSuccess;

  const GuestFormDialog({
    super.key,
    required this.eventId,
    this.guest,
    required this.onSuccess,
  });

  @override
  State<GuestFormDialog> createState() => _GuestFormDialogState();
}

class _GuestFormDialogState extends State<GuestFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _service = GuestService();
  
  // Single Entry Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _dietaryController;
  late TextEditingController _notesController;
  
  late int _guestCount;
  late int _plusOneCount;
  String? _selectedMeal;
  String? _rsvpStatus;
  
  // Bulk Mode Logic
  bool _isBulkMode = false;
  final List<Map<String, TextEditingController>> _bulkGuests = [];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final g = widget.guest;
    
    _firstNameController = TextEditingController(text: g?.firstName ?? '');
    _lastNameController = TextEditingController(text: g?.lastName ?? '');
    _emailController = TextEditingController(text: g?.email ?? '');
    _phoneController = TextEditingController(text: g?.phone ?? '');
    _dietaryController = TextEditingController(text: g?.dietaryRestrictions ?? '');
    _notesController = TextEditingController(text: g?.notes ?? '');
    
    _guestCount = g?.guestCount ?? 1;
    _plusOneCount = g?.plusOneCount ?? 0;
    _selectedMeal = g?.mealPreference;
    _rsvpStatus = g?.rsvpStatus ?? 'pending';

    // Initialize with one empty row for bulk mode
    _bulkGuests.add(_createEmptyBulkRow());
  }

  Map<String, TextEditingController> _createEmptyBulkRow() {
    return {
      "first_name": TextEditingController(),
      "last_name": TextEditingController(),
      "email": TextEditingController(),
      "phone": TextEditingController(),
    };
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dietaryController.dispose();
    _notesController.dispose();
    for (var row in _bulkGuests) {
      row.forEach((key, controller) => controller.dispose());
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    bool success;
    
    if (_isBulkMode && widget.guest == null) {
      // HANDLE BULK IMPORT
      final List<Map<String, String>> guestList = _bulkGuests.map((g) => {
        "first_name": g["first_name"]!.text.trim(),
        "last_name": g["last_name"]!.text.trim(),
        "email": g["email"]!.text.trim(),
        "phone": g["phone"]!.text.trim(),
      }).where((g) => g["first_name"]!.isNotEmpty).toList();

      success = await _service.bulkImportGuests(widget.eventId, guestList);
    } else {
      // HANDLE SINGLE CREATE/UPDATE
      final data = {
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "guest_count": _guestCount,
        "plus_one_count": _plusOneCount,
        "meal_preference": _selectedMeal,
        "dietary_restrictions": _dietaryController.text.trim(),
        "notes": _notesController.text.trim(),
        "rsvp_status": _rsvpStatus,
      };

      if (widget.guest != null) {
        success = await _service.updateGuest(widget.eventId, widget.guest!.id, data);
      } else {
        success = await _service.createGuest(widget.eventId, data);
      }
    }

    if (success && mounted) {
      widget.onSuccess();
      Navigator.pop(context);
      AppAlerts.showPopup(context, widget.guest != null ? "Guest Updated" : "Guests Added Successfully");
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.guest != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        isEdit ? 'Update Guest Profile' : (_isBulkMode ? 'Bulk Add Guests' : 'Add New Guest'),
        style: TextStyle(color: AppColor.blueFont, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Bulk Add Mode", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Add multiple names at once", style: TextStyle(fontSize: 12)),
                    value: _isBulkMode,
                    activeColor: AppColor.primary,
                    onChanged: (val) => setState(() => _isBulkMode = val),
                  ),
                  const Divider(),
                ],

                if (_isBulkMode && !isEdit) _buildBulkForm() else _buildSingleForm(isEdit),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isSubmitting 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(isEdit ? "Update" : "Create", style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBulkForm() {
    return Column(
      children: [
        ..._bulkGuests.asMap().entries.map((entry) {
          int index = entry.key;
          var controllers = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Guest #${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    if (_bulkGuests.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                        onPressed: () => setState(() => _bulkGuests.removeAt(index)),
                      ),
                  ],
                ),
                _buildTextField(controllers["first_name"]!, "First Name"),
                _buildTextField(controllers["last_name"]!, "Last Name"),
                _buildTextField(controllers["email"]!, "Email"),
                _buildTextField(controllers["phone"]!, "Phone"),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => _bulkGuests.add(_createEmptyBulkRow())),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text("Add Another Guest"),
        ),
      ],
    );
  }

  Widget _buildSingleForm(bool isEdit) {
    return Column(
      children: [
        if (isEdit) ...[
          _buildReadOnlyField("Invitation Code", widget.guest!.invitationCode),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(child: _buildTextField(_firstNameController, "First Name")),
            const SizedBox(width: 10),
            Expanded(child: _buildTextField(_lastNameController, "Last Name")),
          ],
        ),
        _buildTextField(_emailController, "Email", keyboard: TextInputType.emailAddress),
        _buildTextField(_phoneController, "Phone", keyboard: TextInputType.phone),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedMeal,
          decoration: const InputDecoration(labelText: "Meal Preference"),
          items: GuestConstants.mealOptions.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
          onChanged: (val) => setState(() => _selectedMeal = val),
        ),
        _buildTextField(_dietaryController, "Dietary Restrictions"),
        _buildTextField(_notesController, "Special Notes", maxLines: 2),
        const SizedBox(height: 15),
        _buildCounter("Main Guests", _guestCount, (v) => setState(() => _guestCount = v), min: 1),
        _buildCounter("Plus Ones", _plusOneCount, (v) => setState(() => _plusOneCount = v)),
        if (isEdit) ...[
          const Divider(),
          DropdownButtonFormField<String>(
            value: _rsvpStatus,
            decoration: const InputDecoration(labelText: "RSVP Status"),
            items: GuestConstants.rsvpOptions.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
            onChanged: (val) => setState(() => _rsvpStatus = val),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboard = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        validator: (v) => (label == "First Name" && v!.isEmpty) ? "Required" : null,
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary)),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged, {int min = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: value > min ? () => onChanged(value - 1) : null),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => onChanged(value + 1)),
          ],
        ),
      ],
    );
  }
}