import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_api.dart';
import 'package:eventak/service-provider-UI/features/show_service/view/edit_service_view.dart';

class ShowServicePage extends StatelessWidget {
  final MyService service;

  const ShowServicePage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.blueFont),
        title: Text(
          'My Service',
          style: TextStyle(
            color: AppColor.blueFont,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Text(
              service.name,
              style: TextStyle(
                color: AppColor.blueFont,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

           
            Row(
              children: [
                if (service.categoryId != null)
                  Chip(
                    label: Text('Category #${service.categoryId}'),
                    backgroundColor: AppColor.beige,
                  ),
                const SizedBox(width: 8),
                if (service.location != null &&
                    service.location!.trim().isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        service.location!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            
            if (service.basePrice != null) ...[
              Text(
                'Price',
                style: TextStyle(
                  color: AppColor.blueFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${service.basePrice!.toStringAsFixed(2)} ${service.priceUnit ?? ''}',
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'Description',
              style: TextStyle(
                color: AppColor.blueFont,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (service.description?.isNotEmpty ?? false)
                  ? service.description!
                  : 'No description provided.',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(
                    color: AppColor.blueFont,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  service.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: service.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                // EDIT BUTTON
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final changed = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditServiceView(service: service),
                        ),
                      );

                      if (changed == true) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Service'),
                  ),
                ),
                const SizedBox(width: 12),

                // DELETE BUTTON
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final confirm =
                          await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Delete service?'),
                              content: const Text(
                                'Are you sure you want to delete this service?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogCtx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogCtx).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (!confirm) return;

                      try {

                        await MyServicesService().deleteService(service.id);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Service deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to delete: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
