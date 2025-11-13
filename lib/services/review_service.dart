import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cookbook/models/review.dart';

class ReviewService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Submit or update a review for a recipe
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

    final reviewRef = _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(userId);

    final existingReview = await reviewRef.get();
    final now = DateTime.now();

    final review = Review(
      reviewId: userId,
      recipeId: recipeId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: existingReview.exists 
          ? (existingReview.data()!['createdAt'] as Timestamp).toDate()
          : now,
      updatedAt: existingReview.exists ? now : null,
    );

    await reviewRef.set(review.toJson());

    // Update recipe's average rating
    await _updateRecipeRating(recipeId);
  }

  /// Get user's review for a recipe
  static Future<Review?> getUserReview(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(userId)
        .get();

    if (!doc.exists) return null;
    return Review.fromJson(doc.data()!);
  }

  /// Stream user's review for a recipe
  static Stream<Review?> getUserReviewStream(String recipeId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? Review.fromJson(doc.data()!) : null);
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

  /// Delete a review
  static Future<void> deleteReview(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('recipes')
        .doc(recipeId)
        .collection('reviews')
        .doc(userId)
        .delete();

    await _updateRecipeRating(recipeId);
  }
}
