import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/services/service_details/view/service_details_view.dart';
import 'package:eventak/customer-UI/features/packages/package_details/data/package_model.dart';

class IncludedServicesList extends StatelessWidget {
  final List<PackageItem> items;

  const IncludedServicesList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
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

         
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No services included in this package yet.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )

          else
            Column(
              children: [
                SizedBox(
                  height: 180, 
                  child: Scrollbar(
                    controller: controller,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: controller,
                      itemCount: items.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final service = item.service;

                        
                        final String name =
                            service.name.isNotEmpty ? service.name : 'Service';
                        final String description =
                            service.description ?? '';
                        final String type = service.type ?? '';
                        final double rating =
                            service.averageRating ?? 0.0;
                        final int quantity = item.quantity ?? 1;

                        return InkWell(
                          onTap: service.id != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceDetailsView(
                                        serviceId: service.id!,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                             
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: service.image != null &&
                                          service.image!.isNotEmpty
                                      ? Image.network(
                                          service.image!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image,
                                            size: 20,
                                          ),
                                        ),
                                ),

                                const SizedBox(width: 12),

                               
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              name,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'x$quantity',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColor.primary,
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 6),

                                      
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 14,
                                              color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            rating.toStringAsFixed(1),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          const SizedBox(width: 12),

                                          if (type.isNotEmpty)
                                            Flexible(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColor.beige
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                ),
                                                child: Text(
                                                  type,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppColor.primary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                if (items.length > 2)
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      'Scroll to see more services',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
