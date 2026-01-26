import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/packages/packages_list/view/package_list_view.dart';

class HomeCarousel extends StatefulWidget {
  final List<Map<String, String>> carouselItems;

  const HomeCarousel({super.key, required this.carouselItems});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  int _carouselIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openPackages(String categoryName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PackagesListView(
          selectedCategory: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.carouselItems.length,
                    onPageChanged: (index) => setState(() => _carouselIndex = index),
                    itemBuilder: (context, index) {
                      final item = widget.carouselItems[index];
                      return GestureDetector(
                        onTap: () {
                          
                          final categoryName = item['title']!.split(' ').first;
                          _openPackages(categoryName);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              image: DecorationImage(
                                image: AssetImage(item['img']!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.25),
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
                                ),
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
          ),

          const SizedBox(width: 8),
          _buildViewAllButton(),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _openPackages('All'),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'View All',
          style: TextStyle(fontSize: 12),
        ),
      ],
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
