import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cookbook/services/review_service.dart';
import 'package:cookbook/models/review.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cookbook/utils/utils.dart';

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

  void _showAddReviewBottomSheet({Review? reviewToEdit}) {
    if (_isOwnRecipe()) {
      Utils().showWarning('You cannot rate your own recipe');
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
        existingReview: reviewToEdit,
        onReviewSubmitted: () {
          setState(() {});
          Navigator.pop(context);
          Utils().showSuccess(
            reviewToEdit != null 
                ? 'Review updated successfully!'
                : 'Thank you for your review!',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    return FutureBuilder<Map<String, dynamic>>(
      future: ReviewService.getReviewStats(widget.recipeId),
      builder: (context, statsSnapshot) {
        final stats = statsSnapshot.data;
        final averageRating = stats?['averageRating'] ?? widget.currentRating;
        final totalReviews = stats?['totalReviews'] ?? widget.reviewCount;
        final distribution = stats?['distribution'] as Map<int, int>? ?? {};

        return StreamBuilder<List<Review>>(
          stream: ReviewService.getRecipeReviews(widget.recipeId),
          builder: (context, reviewsSnapshot) {
            // Check if user has already reviewed
            final allReviews = reviewsSnapshot.data ?? [];
            final userReview = allReviews.firstWhere(
              (review) => review.userId == currentUserId,
              orElse: () => Review(
                reviewId: '',
                recipeId: '',
                userId: '',
                userName: '',
                rating: 0,
                comment: null,
                createdAt: DateTime.now(),
              ),
            );
            final hasUserReviewed = userReview.reviewId.isNotEmpty;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Summary Card
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
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
                        // Add Review Button or Already Reviewed Message
                        if (!_isOwnRecipe())
                          hasUserReviewed
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'You\'ve reviewed this recipe',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(
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

                  // Display reviews
                  if (reviewsSnapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (!reviewsSnapshot.hasData || reviewsSnapshot.data!.isEmpty)
                    Center(
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
                    )
                  else
                    Builder(
                      builder: (context) {
                        // Separate user's review and others
                        final otherReviews = allReviews
                            .where((review) => review.userId != currentUserId)
                            .toList();
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: hasUserReviewed 
                              ? otherReviews.length + 1 
                              : otherReviews.length,
                          itemBuilder: (context, index) {
                            // Show user's review first
                            if (index == 0 && hasUserReviewed) {
                              return _buildReviewCard(userReview, isHighlighted: true);
                            }
                            // Show other reviews
                            final reviewIndex = hasUserReviewed ? index - 1 : index;
                            return _buildReviewCard(otherReviews[reviewIndex]);
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewCard(Review review, {bool isHighlighted = false}) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnReview = currentUserId == review.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Avatar (smaller)
                CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 18,
                  child: Text(
                    review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username and You badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.userName,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (isOwnReview) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                'You',
                                style: GoogleFonts.lato(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Time ago and edited indicator
                      Row(
                        children: [
                          Text(
                            _formatTimeAgo(review.createdAt),
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (review.updatedAt != null) ...[
                            Text(
                              ' • ',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                            Text(
                              'Edited',
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Rating Stars (horizontal)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            // Comment section
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      review.comment!,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                  // Three-dot menu in bottom-right corner (only for own reviews)
                  if (isOwnReview) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: Icon(Icons.more_horiz, color: Colors.grey[500]),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddReviewBottomSheet(reviewToEdit: review);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(review);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: Colors.grey[700]),
                              const SizedBox(width: 8),
                              const Text('Edit', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 16, color: Colors.red),
                              const SizedBox(width: 8),
                              const Text('Delete', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
            // If no comment but own review, show menu button in bottom-right
            if ((review.comment == null || review.comment!.isEmpty) && isOwnReview) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 18,
                  icon: Icon(Icons.more_horiz, color: Colors.grey[500]),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showAddReviewBottomSheet(reviewToEdit: review);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(review);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          const Text('Edit', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('Delete', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Review?',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
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
                await ReviewService.deleteReview(widget.recipeId, review.reviewId);
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
}

// Bottom Sheet for Adding/Editing Review
class _AddReviewBottomSheet extends StatefulWidget {
  final String recipeId;
  final Review? existingReview;
  final VoidCallback onReviewSubmitted;

  const _AddReviewBottomSheet({
    required this.recipeId,
    this.existingReview,
    required this.onReviewSubmitted,
  });

  @override
  State<_AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<_AddReviewBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing existing review, populate fields
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment ?? '';
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      Utils().showWarning('Please select a rating');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      if (widget.existingReview != null) {
        // Update existing review
        await ReviewService.updateReview(
          recipeId: widget.recipeId,
          reviewId: widget.existingReview!.reviewId,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty 
              ? null 
              : _commentController.text.trim(),
        );
      } else {
        // Create new review
        await ReviewService.submitReview(
          recipeId: widget.recipeId,
          rating: _rating,
          comment: _commentController.text.trim().isEmpty 
              ? null 
              : _commentController.text.trim(),
        );
      }

      widget.onReviewSubmitted();
    } catch (e) {
      if (mounted) {
        Utils().showError('Failed to submit review. Please try again.');
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
                widget.existingReview != null ? 'Edit Your Review' : 'Write a Review',
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
                      widget.existingReview != null ? 'Update Review' : 'Submit Review',
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
