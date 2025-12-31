import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class AddServiceDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableServices;
  final Function(int serviceId, int quantity) onAdd;

  const AddServiceDialog({
    super.key,
    required this.availableServices,
    required this.onAdd,
  });

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  int? selectedServiceId;
  final TextEditingController qtyController = TextEditingController(text: "1");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Service", style: TextStyle(color: AppColor.blueFont)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: "Select Service"),
            items: widget.availableServices.map((s) {
              return DropdownMenuItem<int>(
                value: s['id'],
                child: Text(s['name'] ?? 'Unnamed'),
              );
            }).toList(),
            onChanged: (val) => setState(() => selectedServiceId = val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: qtyController,
            decoration: const InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          onPressed: () {
            if (selectedServiceId != null) {
              final qty = int.tryParse(qtyController.text) ?? 1;
              widget.onAdd(selectedServiceId!, qty); 
              Navigator.pop(context);
            }
          },
          child: const Text("Add", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class UpdateQuantityDialog extends StatelessWidget {
  final int initialQuantity;
  final Function(int newQuantity) onUpdate;

  const UpdateQuantityDialog({
    super.key,
    required this.initialQuantity,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialQuantity.toString());
    
    return AlertDialog(
      title: Text("Update Quantity", style: TextStyle(color: AppColor.blueFont)),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: "Enter number"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final val = int.tryParse(controller.text) ?? initialQuantity;
            onUpdate(val);
            Navigator.pop(context);
          },
          child: Text(
            "Update",
            style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}