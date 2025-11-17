import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cookbook/models/review.dart';
import 'package:cookbook/services/review_service.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/utils/utils.dart';
import 'package:cookbook/widgets/my_drawer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Map<String, dynamic>>> _getAllUserReviews() {
    if (currentUserId == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collectionGroup('reviews')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> reviewsWithRecipes = [];

      for (var doc in snapshot.docs) {
        final review = Review.fromJson(doc.data());
        
        // Fetch recipe details
        final recipeDoc = await FirebaseFirestore.instance
            .collection('recipes')
            .doc(review.recipeId)
            .get();

        if (recipeDoc.exists) {
          final recipeData = recipeDoc.data()!;
          reviewsWithRecipes.add({
            'review': review,
            'recipeName': recipeData['name'] ?? 'Unknown Recipe',
            'recipeImage': recipeData['imageUrl'] ?? recipeData['image'] ?? '',
          });
        }
      }

      return reviewsWithRecipes;
    });
  }

  void _showEditReviewDialog(Review review, String recipeName) {
    final TextEditingController commentController = TextEditingController(text: review.comment ?? '');
    double rating = review.rating;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Edit Review',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipe: $recipeName',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rating',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 40,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (newRating) {
                      setState(() => rating = newRating);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: 'Comment (Optional)',
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ReviewService.updateReview(
                    recipeId: review.recipeId,
                    reviewId: review.reviewId,
                    rating: rating,
                    comment: commentController.text.trim().isEmpty 
                        ? null 
                        : commentController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    Utils().showSuccess('Review updated successfully!');
                  }
                } catch (e) {
                  if (mounted) {
                    Utils().showError('Failed to update review. Please try again.');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: Text(
                'Update',
                style: GoogleFonts.lato(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Review review, String recipeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Review?',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete your review for "$recipeName"? This action cannot be undone.',
          style: GoogleFonts.lato(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ReviewService.deleteReview(review.recipeId, review.reviewId);
                if (mounted) {
                  Utils().showSuccess('Review deleted successfully');
                }
              } catch (e) {
                if (mounted) {
                  Utils().showError('Failed to delete review. Please try again.');
                }
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.lato(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(context, currentRoute: '/my-reviews'),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Reviews',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [bgc1, bgc2, bgc3, bgc4],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getAllUserReviews(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading reviews',
                        style: GoogleFonts.lato(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final reviews = snapshot.data ?? [];

              if (reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 80,
                        color: primaryColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Reviews Yet',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Reviews you leave on recipes will appear here',
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final data = reviews[index];
                  final review = data['review'] as Review;
                  final recipeName = data['recipeName'] as String;
                  final recipeImage = data['recipeImage'] as String;
                  
                  final daysSinceCreation = DateTime.now().difference(review.createdAt).inDays;
                  final canEdit = daysSinceCreation <= 30;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recipe info
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: recipeImage.isNotEmpty
                                        ? Image.network(
                                            recipeImage,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.teal[50],
                                              child: Icon(
                                                Icons.restaurant,
                                                color: Colors.teal,
                                                size: 28,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.teal[50],
                                            child: Icon(
                                              Icons.restaurant,
                                              color: Colors.teal,
                                              size: 28,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipeName,
                                        style: GoogleFonts.lato(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatTimeAgo(review.createdAt),
                                            style: GoogleFonts.lato(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          if (review.updatedAt != null) ...[
                                            Text(
                                              ' • ',
                                              style: GoogleFonts.lato(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                            Text(
                                              'Edited',
                                              style: GoogleFonts.lato(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (canEdit) ...[
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.orange[100]!,
                                                Colors.orange[50]!,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.orange[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 13,
                                                color: Colors.orange[800],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${30 - daysSinceCreation} days left to edit',
                                                style: GoogleFonts.lato(
                                                  fontSize: 11,
                                                  color: Colors.orange[800],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (canEdit)
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    iconSize: 22,
                                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditReviewDialog(review, recipeName);
                                        } else if (value == 'delete') {
                                          _showDeleteConfirmation(review, recipeName);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit_outlined, size: 18, color: primaryColor),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Edit',
                                                style: GoogleFonts.lato(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Delete',
                                                style: GoogleFonts.lato(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Divider(color: Colors.grey[200], height: 1),
                            const SizedBox(height: 12),
                            // Rating
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < review.rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber[600],
                                  size: 22,
                                );
                              }),
                            ),
                            // Comment
                            if (review.comment != null && review.comment!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  review.comment!,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
