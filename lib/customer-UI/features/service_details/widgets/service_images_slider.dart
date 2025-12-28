import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class ServiceImages extends StatefulWidget {
  const ServiceImages({super.key});

  @override
  State<ServiceImages> createState() => _ServiceImagesState();
}

class _ServiceImagesState extends State<ServiceImages> {
  final List<String> serviceImages = [
    'assets/App_photos/wedding.jpg',
    'assets/App_photos/Birthday-Cake-1.webp',
    'assets/App_photos/Graduation.jpg',
  ];

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
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
                  child: Image.asset(
                    serviceImages[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
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
