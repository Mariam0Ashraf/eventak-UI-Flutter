import 'package:flutter/material.dart';
import 'package:eventak/core/constants/app-colors.dart';
import 'package:eventak/customer-UI/features/service_details/data/reviews_service.dart';
import 'package:eventak/customer-UI/features/service_details/data/review_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewsTab extends StatefulWidget {
  final int serviceId;
  final VoidCallback? onReviewChanged;
  const ReviewsTab({super.key, required this.serviceId, this.onReviewChanged});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  int? _currentUserId;
  final _reviewsApi = ReviewsService();
  List<Review> _reviews = [];
  bool _loading = true;
  Review? _myReview;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('user_id');
    await _loadReviews();
  }

 Future<void> _loadReviews({bool loadMore = false}) async {
  if (loadMore && _currentPage >= _lastPage) return;

  if (loadMore) {
    _loadingMore = true;
    _currentPage++;
  } else {
    _loading = true;
    _currentPage = 1;
    _reviews.clear();
  }

  try {
    final res = await _reviewsApi.getReviews(
      serviceId: widget.serviceId,
      page: _currentPage,
    );

    setState(() {
      _myReview = res.myReview;
      final others = res.reviews.where((r) {
        return _myReview == null || r.id != _myReview!.id;
      }).toList();

      _reviews.addAll(others);
      _lastPage = res.lastPage;
      _loading = false;
      _loadingMore = false;
    });
  } catch (e) {
    debugPrint(e.toString());
    setState(() {
      _loading = false;
      _loadingMore = false;
    });
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
              icon: Icon(
                Icons.send,
                size: 18,
                color: canSend ? AppColor.primary : Colors.grey,
              ),
              onPressed: canSend
                  ? () async {
                      final review = _reviewController.text.trim();
                      if (review.isEmpty || _selectedRating == 0) return;

                      await _reviewsApi.createReview(
                        serviceId: widget.serviceId,
                        rating: _selectedRating,
                        comment: review,
                      );
                      widget.onReviewChanged?.call();

                      _reviewController.clear();
                      setState(() => _selectedRating = 0);

                      //_loadReviews();
                      await _loadReviews(loadMore: false);

                    }
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _reviewItem({required Review review}) {
    final isMyReview = review.userId == _currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      review.date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (isMyReview)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditReviewDialog(review);
                          } else {
                            _confirmDelete(review.id);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Update Review'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete Review',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(review.comment),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _confirmDelete(int reviewId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _reviewsApi.deleteReview(reviewId);
              _loadReviews();
              widget.onReviewChanged?.call();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditReviewDialog(Review review) {
    final controller = TextEditingController(text: review.comment);
    int rating = review.rating;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => rating = i + 1),
                  ),
                ),
              ),
              TextField(controller: controller),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _reviewsApi.updateReview(
                  reviewId: review.id,
                  rating: rating,
                  comment: controller.text.trim(),
                );
                Navigator.of(context).pop();
                _loadReviews();
                widget.onReviewChanged?.call();
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
      child: ListView(
        
        children: [
          const Text(
            'Reviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          
          if (_myReview == null) ...[
            _buildStarRatingInput(),
            const SizedBox(height: 6),
            _buildReviewTextBox(),
            const SizedBox(height: 16),
          ] else ...[
            const Text(
              'Your Review',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _reviewItem(review: _myReview!),
            const Divider(height: 8),
          ],

          // All other reviews
          ..._reviews.map((review) => _reviewItem(review: review)),

          // Loading more indicator
          if (_currentPage < _lastPage)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
