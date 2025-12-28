import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/service_details/data/reviews_service.dart';
import 'package:eventak/customer-UI/features/service_details/data/review_model.dart';

class ReviewsTab extends StatefulWidget {
  final int serviceId;

  const ReviewsTab({super.key, required this.serviceId});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  final _reviewsApi = ReviewsService();
  List<Review> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    
    try {
      final res = await _reviewsApi.getReviews(widget.serviceId);
      setState(() {
        _reviews = res;
        _loading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() => _loading = false);
    }
  }

  Widget _buildStarRatingInput() {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            index < _selectedRating ? Icons.star : Icons.star_border,
            size: 18,
            color: Colors.amber,
          ),
          onPressed: () {
            setState(() => _selectedRating = index + 1);
          },
        );
      }),
    );
  }

 Widget _buildReviewTextBox() {
  return ValueListenableBuilder<TextEditingValue>(
    valueListenable: _reviewController,
    builder: (context, value, child) {
      final canSend = value.text.trim().isNotEmpty && _selectedRating > 0;

      return TextField(
        controller: _reviewController,
        maxLines: 1,
        decoration: InputDecoration(
          labelText: 'Add your review',
          filled: true,
          fillColor: AppColor.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.send, size: 18, color: canSend ? AppColor.primary : Colors.grey),
            onPressed: canSend
                ? () async {
                    final review = _reviewController.text.trim();
                    if (review.isEmpty || _selectedRating == 0) return;

                    await _reviewsApi.createReview(
                      serviceId: widget.serviceId,
                      rating: _selectedRating,
                      comment: review,
                    );

                    _reviewController.clear();
                    setState(() => _selectedRating = 0);

                    _loadReviews();
                  }
                : null,
          ),
        ),
      );
    },
  );
}


  Widget _reviewItem({
    required String name,
    required int rating,
    required String review,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 18, child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(review, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          _buildStarRatingInput(),
          const SizedBox(height: 6),
          _buildReviewTextBox(),
          const SizedBox(height: 16),

          
          Expanded(
            child: _reviews.isEmpty
                ? const Center(child: Text('No reviews yet'))
                : ListView.builder(
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      final r = _reviews[index];
                      return _reviewItem(
                        name: r.userName ,
                        rating: r.rating,
                        review: r.comment,
                        date: r.date,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
