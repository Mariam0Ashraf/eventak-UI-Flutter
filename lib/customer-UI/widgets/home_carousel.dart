// lib/customer-UI/shared/widgets/home_carousel.dart

import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';

class HomeCarousel extends StatefulWidget {
  final List<Map<String, String>> carouselItems;

  const HomeCarousel({
    super.key,
    required this.carouselItems,
  });

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  int _carouselIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.carouselItems.length,
              onPageChanged: (index) => setState(() => _carouselIndex = index),
              itemBuilder: (context, index) {
                final item = widget.carouselItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 6.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.beige,
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        // Note: Using NetworkImage for assets is unusual, 
                        // but maintaining original logic for now.
                        image: NetworkImage(item['img']!), 
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          AppColor.beige.withOpacity(0.15),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        item['title']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: Colors.black45,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          _buildDots(),
        ],
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.carouselItems.length, (i) {
        final isActive = i == _carouselIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColor.primary
                : AppColor.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}