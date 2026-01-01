import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class PackageItemForm extends StatefulWidget {
  final ValueNotifier<List<Map<String, dynamic>>> servicesNotifier;
  final Function(Map<String, dynamic>) onAdd;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  const PackageItemForm({
    super.key,
    required this.servicesNotifier,
    required this.onAdd,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoadingMore,
  });

  @override
  State<PackageItemForm> createState() => _PackageItemFormState();
}

class _PackageItemFormState extends State<PackageItemForm> {
  int? _serviceId;
  String? _serviceName;
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _showServicePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: widget.servicesNotifier,
          builder: (context, services, _) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                scrollController.addListener(() {
                  if (scrollController.position.pixels >=
                      scrollController.position.maxScrollExtent - 100) {
                    if (widget.hasMore && !widget.isLoadingMore) {
                      widget.onLoadMore();
                    }
                  }
                });

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "Select Service",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColor.blueFont,
                        ),
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
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final s = services[index];
                            return ListTile(
                              title: Text(s['name'] ?? 'Unnamed'),
                              subtitle: Text("${s['base_price'] ?? '0'} EGP"),
                              onTap: () {
                                setState(() {
                                  _serviceId = s['id'];
                                  _serviceName = s['name'];
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
    return Column(
      children: [
        InkWell(
          onTap: _showServicePicker,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Select Service',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
            child: Text(
              _serviceName ?? "Tap to choose a service",
              style: TextStyle(
                color: _serviceName == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _qtyController,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              if (_serviceId != null) {
                widget.onAdd({
                  "service_id": _serviceId,
                  "service_name": _serviceName,
                  "quantity": int.tryParse(_qtyController.text) ?? 1,
                });
                setState(() {
                  _serviceId = null;
                  _serviceName = null;
                  _qtyController.text = "1";
                });
              }
            },
            child: const Text(
              "Add to Package",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}