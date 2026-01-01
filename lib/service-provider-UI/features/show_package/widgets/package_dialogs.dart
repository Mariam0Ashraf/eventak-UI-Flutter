import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class AddServiceDialog extends StatefulWidget {
  final ValueNotifier<List<Map<String, dynamic>>> servicesNotifier;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Function(int serviceId, int quantity) onAdd;

  const AddServiceDialog({
    super.key,
    required this.servicesNotifier,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onAdd,
  });

  @override
  State<AddServiceDialog> createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  int? selectedServiceId;
  String? selectedServiceName;
  final TextEditingController qtyController = TextEditingController(text: "1");

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: widget.servicesNotifier,
          builder: (context, services, _) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                scrollController.addListener(() {
                  if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 50) {
                    widget.onLoadMore(); 
                  }
                });

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("Select Service", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColor.blueFont)),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: services.length + (widget.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == services.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final s = services[index];
                          return ListTile(
                            title: Text(s['name'] ?? 'Unnamed'),
                            subtitle: Text("${s['base_price'] ?? '0'} EGP"),
                            onTap: () {
                              setState(() {
                                selectedServiceId = s['id'];
                                selectedServiceName = s['name'];
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Service", style: TextStyle(color: AppColor.blueFont)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _showPicker,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: "Service", border: OutlineInputBorder()),
              child: Text(selectedServiceName ?? "Select Service"),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: qtyController,
            decoration: const InputDecoration(labelText: "Quantity", border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColor.primary),
          onPressed: () {
            if (selectedServiceId != null) {
              widget.onAdd(selectedServiceId!, int.tryParse(qtyController.text) ?? 1);
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
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