import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cookbook/models/review.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit a new review for a recipe (allows multiple reviews per user)
  static Future<void> submitReview({
    required String recipeId,
    required double rating,
    String? comment,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    // Get user name
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userName = userDoc.data()?['name'] ?? 'Anonymous';

    // Use auto-generated ID to allow multiple reviews per user
    final reviewRef = _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(); // Auto-generate document ID

    final now = DateTime.now();

    final review = Review(
      reviewId: reviewRef.id, // Use the auto-generated ID
      recipeId: recipeId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: now,
      updatedAt: null,
    );

    await reviewRef.set(review.toJson());

    // Update recipe's average rating
    await _updateRecipeRating(recipeId);
  }

  /// Get all reviews by a specific user for a recipe
  static Future<List<Review>> getUserReviews(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList();
  }

  /// Stream all reviews by a specific user for a recipe
  static Stream<List<Review>> getUserReviewsStream(String recipeId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList());
  }

  /// Get all reviews for a recipe
  static Stream<List<Review>> getRecipeReviews(String recipeId) {
    return _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Review.fromJson(doc.data())).toList());
  }

  /// Get rating statistics for a recipe
  static Future<Map<String, dynamic>> getReviewStats(String recipeId) async {
    final reviews = await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .get();

    if (reviews.docs.isEmpty) {
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'distribution': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }

    double totalRating = 0;
    Map<int, int> distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var doc in reviews.docs) {
      final rating = (doc.data()['rating'] as num).toDouble();
      totalRating += rating;
      distribution[rating.round()] = (distribution[rating.round()] ?? 0) + 1;
    }

    return {
      'averageRating': totalRating / reviews.docs.length,
      'totalReviews': reviews.docs.length,
      'distribution': distribution,
    };
  }

  /// Update recipe's average rating
  static Future<void> _updateRecipeRating(String recipeId) async {
    final stats = await getReviewStats(recipeId);
    await _firestore.collection('recipes').doc(recipeId).update({
      'rating': stats['averageRating'],
      'reviewCount': stats['totalReviews'],
    });
  }

  /// Update an existing review
  static Future<void> updateReview({
    required String recipeId,
    required String reviewId,
    required double rating,
    String? comment,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final reviewRef = _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(reviewId);

    final reviewDoc = await reviewRef.get();
    if (!reviewDoc.exists) throw Exception('Review not found');

    // Verify user owns this review
    if (reviewDoc.data()?['userId'] != userId) {
      throw Exception('Unauthorized to edit this review');
    }

    await reviewRef.update({
      'rating': rating,
      'comment': comment,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Update recipe's average rating
    await _updateRecipeRating(recipeId);
  }

  /// Delete a review
  static Future<void> deleteReview(String recipeId, String reviewId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final reviewRef = _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(reviewId);

    final reviewDoc = await reviewRef.get();
    if (!reviewDoc.exists) throw Exception('Review not found');

    // Verify user owns this review
    if (reviewDoc.data()?['userId'] != userId) {
      throw Exception('Unauthorized to delete this review');
    }

    await reviewRef.delete();

    await _updateRecipeRating(recipeId);
  }
}
