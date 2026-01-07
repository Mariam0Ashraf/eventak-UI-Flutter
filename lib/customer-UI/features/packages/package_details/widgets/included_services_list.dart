import 'package:eventak/core/constants/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:eventak/customer-UI/features/service_details/view/service_details_view.dart';
import 'package:eventak/customer-UI/features/packages/package_details/data/package_model.dart';
import 'package:eventak/customer-UI/features/service_details/data/service_model.dart'; 

class IncludedServicesList extends StatelessWidget {
  final List<PackageItem> items;

  const IncludedServicesList({super.key, required this.items});

  /// category name 
  String _getCategory(ServiceData service) {
    if (service.categoryName != null && service.categoryName!.isNotEmpty) {
      return service.categoryName!;
    }
    return 'No Category Provided'; // fallback placeholder
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Approx height for 2 items
    final double containerHeight =
        items.length > 2 ? 2 * 96.0 + 28.0 : items.length * 96.0 + 28.0;

    return SizedBox(
      height: containerHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title inside widget
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Included Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // List of services
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.symmetric(vertical: 0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = items[index];
                final service = item.service;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceDetailsView(
                          serviceId: service.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.15)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Service info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 2),

                              // Description first
                              if (service.description != null &&
                                  service.description!.isNotEmpty)
                                Text(
                                  service.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),

                              const SizedBox(height: 2),

                              // Category | Rating row
                              Row(
                                children: [
                                  Text(
                                    _getCategory(service),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 2),
                                  Text(
                                    service.averageRating?.toStringAsFixed(1) ??
                                        '0.0',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blueGrey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Quantity pill on the far right
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColor.beige.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'x${item.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
