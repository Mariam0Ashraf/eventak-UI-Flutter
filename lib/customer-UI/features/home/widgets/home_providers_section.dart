import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/home/widgets/section_header.dart';
import 'package:eventak/customer-UI/features/services/list_services/widgets/service_providers_tabs.dart';

IconData getIconData(String? iconName) {
  switch (iconName) {
    case 'face_retouching_natural': return Icons.face_retouching_natural;
    case 'restaurant': return Icons.restaurant;
    case 'lightbulb': return Icons.lightbulb;
    case 'music_note': return Icons.music_note;
    case 'celebration': return Icons.celebration;
    case 'photo_camera': return Icons.photo_camera;
    case 'directions_car': return Icons.directions_car;
    case 'location_city': return Icons.location_city;
    default: return Icons.category; 
  }
}
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
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
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
          height: 140, 
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: apiServiceTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, idx) {
              final item = apiServiceTypes[idx];
              final String title = item['name'] ?? 'Service';
              final String iconString = item['icon'] ?? ''; 

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
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          getIconData(iconString),
                          color: AppColor.primary,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 90,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.blueFont,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}