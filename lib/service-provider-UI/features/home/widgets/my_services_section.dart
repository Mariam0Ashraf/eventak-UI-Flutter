import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/home/widgets/reusable_wedgits.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/show_service_data.dart';


class ServiceCard extends StatelessWidget {
  
  final MyService service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic activeRaw = service.isActive;
  final bool isActive = activeRaw == null
      ? true 
      : (activeRaw is bool 
          ? activeRaw 
          : activeRaw.toString() == '1' || activeRaw.toString() == 'active');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColor.blueFont.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                service.image ?? 'https://via.placeholder.com/150',
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          service.name ?? 'Unnamed Service',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description ?? 'No description provided',
                    style: TextStyle(color: AppColor.grey, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServicesSection extends StatelessWidget {
  final List<Map<String, dynamic>> services;
  final VoidCallback onSeeAll;
  final Function(Map<String, dynamic>) onServiceTap;

  const ServicesSection({
    super.key,
    required this.services,
    required this.onSeeAll,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    print("DEBUG: Services list count = ${services.length}");
    return Column(
      children: [
        SectionHeader(
          title: 'My Services',
          buttonText: 'See All',
          onPressed: onSeeAll,
          showIcon: false,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220, 
          child: services.isEmpty
              ? const EmptyState(
                  message: 'No services found.',
                  icon: Icons.business_center_outlined,
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final model = MyService.fromJson(services[index]);
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ServiceCard(
                        service: model,
                        onTap: () => onServiceTap(services[index]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}