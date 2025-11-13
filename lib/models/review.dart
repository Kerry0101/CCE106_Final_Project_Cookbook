import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewId;
  final String recipeId;
  final String userId;
  final String userName;
  final double rating; // 1-5 stars
  final String? comment; // Optional review text
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.reviewId,
    required this.recipeId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  static Review fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] ?? '',
      recipeId: json['recipeId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Anonymous',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null 
          ? (json['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }
}
