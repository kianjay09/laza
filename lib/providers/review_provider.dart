import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;

  void listenToProductReviews(String productId) {
    _isLoading = true;
    notifyListeners();

    _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
          _reviews =
              snapshot.docs.map((doc) {
                return Review.fromMap(doc.id, doc.data());
              }).toList();
          _isLoading = false;
          notifyListeners();
        });
  }

  Future<void> addReview(
    String productId,
    String userId,
    String userName,
    int rating,
    String comment,
  ) async {
    _setLoading(true);

    try {
      final newReview = Review(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: productId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
        date: DateTime.now(),
      );

      await _firestore
          .collection('reviews')
          .doc(newReview.id)
          .set(newReview.toMap());

      // Update product rating
      await _updateProductRating(productId);

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      debugPrint('Error adding review: $e');
    }
  }

  Future<void> _updateProductRating(String productId) async {
    final reviewsSnapshot =
        await _firestore
            .collection('reviews')
            .where('productId', isEqualTo: productId)
            .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] ?? 0);
    }

    final averageRating = totalRating / reviewsSnapshot.docs.length;
    final reviewCount = reviewsSnapshot.docs.length;

    await _firestore.collection('products').doc(productId).update({
      'rating': averageRating,
      'reviewCount': reviewCount,
    });
  }

  List<Review> getReviewsForProduct(String productId) {
    return _reviews.where((r) => r.productId == productId).toList();
  }

  double getAverageRatingForProduct(String productId) {
    final productReviews = getReviewsForProduct(productId);
    if (productReviews.isEmpty) return 0;
    double sum = 0;
    for (var review in productReviews) {
      sum += review.rating;
    }
    return sum / productReviews.length;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
