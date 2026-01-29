import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import '../data/budget_service.dart';
import '../data/budget_model.dart';

class CreateBudgetItemDialog extends StatefulWidget {
  final int eventId;
  final BudgetItem? item; 
  final VoidCallback onSuccess;

  const CreateBudgetItemDialog({
    super.key,
    required this.eventId,
    required this.onSuccess,
    this.item,
  });

  @override
  State<CreateBudgetItemDialog> createState() => _CreateBudgetItemDialogState();
}

class _CreateBudgetItemDialogState extends State<CreateBudgetItemDialog> {
  final _service = BudgetService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _estimatedController;
  late TextEditingController _actualController;
  late TextEditingController _paidController;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.itemName ?? '');
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
    _estimatedController = TextEditingController(text: widget.item?.estimatedCost.toString() );
    _actualController = TextEditingController(text: widget.item?.actualCost.toString() );
    _paidController = TextEditingController(text: widget.item?.paidAmount.toString() );
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      "category": _categoryController.text.trim(),
      "item_name": _nameController.text.trim(),
      "estimated_cost": double.tryParse(_estimatedController.text) ?? 0.0,
      "actual_cost": double.tryParse(_actualController.text) ?? 0.0,
      "paid_amount": double.tryParse(_paidController.text) ?? 0.0,
      "notes": _notesController.text.trim(),
    };

    bool success;
    if (widget.item != null) {
      success = await _service.updateBudgetItem(widget.eventId, widget.item!.id, data);
    } else {
      success = await _service.createBudgetItem(widget.eventId, data);
    }

    if (success && mounted) {
      widget.onSuccess();
      Navigator.pop(context);
    } else {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item != null ? 'Update Budget Item' : 'New Budget Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Item Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _estimatedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Estimated Cost"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _actualController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Actual Cost"),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _paidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Paid Amount"),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary, foregroundColor: Colors.white),
          child: _isSubmitting 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : Text(widget.item != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}