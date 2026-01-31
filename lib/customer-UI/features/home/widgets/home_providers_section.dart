
import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/widgets/section_header.dart';
import 'package:eventak/customer-UI/features/services/list_services/widgets/service_providers_tabs.dart';

class HomeProvidersSection extends StatelessWidget {
  final List<Map<String, dynamic>> apiServiceTypes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onViewAll;

  const HomeProvidersSection({
    super.key,
    required this.apiServiceTypes,
    required this.isLoading,
    this.errorMessage,
    this.onViewAll
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    }

    return Column(
      children: [
        SectionHeader(
          title: 'Available Services',
          onViewAll: onViewAll ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllServicesTabsView(
                  categories: apiServiceTypes, 
                )
              ),
            );
          },
        ),
        SizedBox(
          height: 190,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: apiServiceTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final item = apiServiceTypes[idx];
                final String title = item['name'] ?? 'Service';
                                final String apiImageUrl = item['image_url'] ?? ''; 

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllServicesTabsView(
                          categories: apiServiceTypes,
                          initialIndex: idx, 
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.primary.withOpacity(0.06)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            apiImageUrl.isNotEmpty ? apiImageUrl : 'invalid_placeholder_url',
                            height: 90,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/logos/logo.png', 
                                height: 90,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColor.blueFont,
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
    );
  }
}