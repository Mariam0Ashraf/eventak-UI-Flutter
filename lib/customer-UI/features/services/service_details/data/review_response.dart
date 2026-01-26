import 'review_model.dart';

class ReviewsResponse {
  final Review? myReview;
  final List<Review> reviews;
  final int currentPage;
  final int lastPage;

  ReviewsResponse({
    required this.myReview,
    required this.reviews,
    required this.currentPage,
    required this.lastPage,
  });
}
