import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cookbook/services/review_service.dart';
import 'package:cookbook/models/review.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeReviewsPage extends StatefulWidget {
  final String recipeId;
  final String recipeOwnerId;
  final double currentRating;
  final int reviewCount;

  const RecipeReviewsPage({
    super.key,
    required this.recipeId,
    required this.recipeOwnerId,
    required this.currentRating,
    this.reviewCount = 0,
  });

  @override
  State<RecipeReviewsPage> createState() => _RecipeReviewsPageState();
}

class _RecipeReviewsPageState extends State<RecipeReviewsPage> {
  bool _isOwnRecipe() {
    return FirebaseAuth.instance.currentUser?.uid == widget.recipeOwnerId;
  }

  String _formatReviewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
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

  void _showAddReviewBottomSheet() {
    if (_isOwnRecipe()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot rate your own recipe',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddReviewBottomSheet(
        recipeId: widget.recipeId,
        onReviewSubmitted: () {
          setState(() {});
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Thank you for your review!',
                style: GoogleFonts.lato(),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ReviewService.getReviewStats(widget.recipeId),
      builder: (context, statsSnapshot) {
        final stats = statsSnapshot.data;
        final averageRating = stats?['averageRating'] ?? widget.currentRating;
        final totalReviews = stats?['totalReviews'] ?? widget.reviewCount;
        final distribution = stats?['distribution'] as Map<int, int>? ?? {};

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Summary Card
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bgc1, bgc2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Average Rating
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Text(
                                totalReviews > 0 ? averageRating.toStringAsFixed(1) : '--',
                                style: GoogleFonts.lato(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < averageRating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 24,
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                totalReviews > 0
                                    ? '${_formatReviewCount(totalReviews)} ${totalReviews == 1 ? 'rating' : 'ratings'}'
                                    : 'No ratings yet',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rating Distribution
                        if (totalReviews > 0)
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: List.generate(5, (index) {
                                final star = 5 - index;
                                final count = distribution[star] ?? 0;
                                final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$star',
                                        style: GoogleFonts.lato(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.star, size: 12, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: percentage,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          count.toString(),
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Add Review Button
                    if (!_isOwnRecipe())
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showAddReviewBottomSheet,
                          icon: const Icon(Icons.rate_review, color: Colors.white),
                          label: Text(
                            'Write a Review',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Reviews List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Reviews',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              StreamBuilder<List<Review>>(
                stream: ReviewService.getRecipeReviews(widget.recipeId),
                builder: (context, reviewsSnapshot) {
                  if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!reviewsSnapshot.hasData || reviewsSnapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reviews yet',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to review this recipe!',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final reviews = reviewsSnapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return _buildReviewCard(review);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // User Avatar
                CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 20,
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(review.createdAt),
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating Stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 18,
                    );
                  }),
                ),
              ],
            ),
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Bottom Sheet for Adding/Editing Review
class _AddReviewBottomSheet extends StatefulWidget {
  final String recipeId;
  final VoidCallback onReviewSubmitted;

  const _AddReviewBottomSheet({
    required this.recipeId,
    required this.onReviewSubmitted,
  });

  @override
  State<_AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<_AddReviewBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;
  Review? _existingReview;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final review = await ReviewService.getUserReview(widget.recipeId);
      if (review != null && mounted) {
        setState(() {
          _existingReview = review;
          _rating = review.rating.toDouble();
          _commentController.text = review.comment ?? '';
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a rating',
            style: GoogleFonts.lato(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      await ReviewService.submitReview(
        recipeId: widget.recipeId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
      );

      widget.onReviewSubmitted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit review: $e',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getEmojiForRating(double rating) {
    if (rating >= 5) return 'Excellent! 🌟';
    if (rating >= 4) return 'Great! 😊';
    if (rating >= 3) return 'Good! 👍';
    if (rating >= 2) return 'Okay 😐';
    if (rating >= 1) return 'Poor 😞';
    return 'Select rating';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _existingReview != null ? 'Edit Your Review' : 'Write a Review',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 48,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() => _rating = rating);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _getEmojiForRating(_rating),
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Your Review (Optional)',
              hintText: 'Share your experience with this recipe...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _existingReview != null ? 'Update Review' : 'Submit Review',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
