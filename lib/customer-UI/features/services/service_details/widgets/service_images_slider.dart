import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/services/service_details/data/service_model.dart';


class ServiceImages extends StatefulWidget {
  final ServiceData service;
  const ServiceImages({super.key, required this.service});

  @override
  State<ServiceImages> createState() => _ServiceImagesState();
}

class _ServiceImagesState extends State<ServiceImages> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // combine main image + gallery
    final serviceImages = [
      if (widget.service.image != null) widget.service.image!,
      ...widget.service.galleryImages,
    ];

    if (serviceImages.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            itemCount: serviceImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    serviceImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(serviceImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentImageIndex == index ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentImageIndex == index
                    ? AppColor.primary
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}
