import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/review_data.dart';
import 'package:eventak/service-provider-UI/features/show_service/data/reviews_api.dart';

class ServiceReviewsSection extends StatefulWidget {
  final int serviceId;

  final bool useDummyIfFailed;

  const ServiceReviewsSection({
    super.key,
    required this.serviceId,
    this.useDummyIfFailed = true,
  });

  @override
  State<ServiceReviewsSection> createState() => _ServiceReviewsSectionState();
}

class _ServiceReviewsSectionState extends State<ServiceReviewsSection> {
  final ReviewsApi _api = ReviewsApi();
  late Future<List<ServiceReview>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ServiceReview>> _load() async {
    try {
      return await _api.getServiceReviews(widget.serviceId);
    } catch (_) {
      if (widget.useDummyIfFailed) {
        return _api.dummyReviews(widget.serviceId);
      }
      rethrow;
    }
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  List<Widget> _buildStars(double rating) {
    return List.generate(5, (i) {
      final starIndex = i + 1;
      if (rating >= starIndex) {
        return const Icon(Icons.star, size: 16, color: Colors.amber);
      }
      if (rating >= starIndex - 0.5) {
        return const Icon(Icons.star_half, size: 16, color: Colors.amber);
      }
      return const Icon(Icons.star_border, size: 16, color: Colors.amber);
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ServiceReview>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load reviews: ${snapshot.error}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Text(
            'No reviews yet.',
            style: TextStyle(
              color: AppColor.blueFont.withOpacity(0.75),
              fontSize: 13,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reviews.map((r) {
            final name = (r.userName?.trim().isNotEmpty ?? false)
                ? r.userName!
                : 'Anonymous';
            final comment = (r.comment?.trim().isNotEmpty ?? false)
                ? r.comment!
                : 'No comment';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: AppColor.blueFont,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(children: _buildStars(r.rating)),
                      const SizedBox(width: 8),
                      
                      
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: TextStyle(
                      color: AppColor.blueFont.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
