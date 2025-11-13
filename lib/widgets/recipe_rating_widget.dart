import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cookbook/services/review_service.dart';
import 'package:cookbook/models/review.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeRatingWidget extends StatefulWidget {
  final String recipeId;
  final String recipeOwnerId;
  final double currentRating;
  final int reviewCount;

  const RecipeRatingWidget({
    super.key,
    required this.recipeId,
    required this.recipeOwnerId,
    required this.currentRating,
    this.reviewCount = 0,
  });

  @override
  State<RecipeRatingWidget> createState() => _RecipeRatingWidgetState();
}

class _RecipeRatingWidgetState extends State<RecipeRatingWidget> {
  bool _isOwnRecipe() {
    return FirebaseAuth.instance.currentUser?.uid == widget.recipeOwnerId;
  }

  void _showRatingBottomSheet() {
    if (_isOwnRecipe()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You cannot rate your own recipe',
            style: GoogleFonts.poppins(),
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
      builder: (context) => _RatingBottomSheet(
        recipeId: widget.recipeId,
        onRatingSubmitted: () {
          setState(() {});
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Thank you for your review!',
                style: GoogleFonts.poppins(),
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
    return InkWell(
      onTap: _showRatingBottomSheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgc1.withOpacity(0.1), bgc2.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 28,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.currentRating > 0
                      ? widget.currentRating.toStringAsFixed(1)
                      : 'No ratings yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor1,
                  ),
                ),
                if (widget.reviewCount > 0)
                  Text(
                    '${widget.reviewCount} ${widget.reviewCount == 1 ? "review" : "reviews"}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textColor1.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            if (!_isOwnRecipe())
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Rate',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RatingBottomSheet extends StatefulWidget {
  final String recipeId;
  final VoidCallback onRatingSubmitted;

  const _RatingBottomSheet({
    required this.recipeId,
    required this.onRatingSubmitted,
  });

  @override
  State<_RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<_RatingBottomSheet> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  Review? _existingReview;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    final reviews = await ReviewService.getUserReviews(widget.recipeId);
    setState(() {
      _existingReview = reviews.isNotEmpty ? reviews.first : null;
      if (_existingReview != null) {
        _rating = _existingReview!.rating;
        _commentController.text = _existingReview!.comment ?? '';
      }
      _isLoading = false;
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a rating',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ReviewService.submitReview(
        recipeId: widget.recipeId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
      );

      widget.onRatingSubmitted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit review. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _existingReview != null ? 'Update Your Review' : 'Rate This Recipe',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textColor1,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: textColor1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _existingReview != null
                  ? 'Change your rating and review'
                  : 'Share your experience with this recipe',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: textColor1.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // Rating Stars
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
                    glow: true,
                    glowColor: Colors.amber.withOpacity(0.3),
                    itemBuilder: (context, index) => Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _rating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_rating > 0)
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _getRatingText(_rating),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Optional Comment
            Text(
              'Review (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor1,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about this recipe...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(16),
              ),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _existingReview != null ? 'Update Review' : 'Submit Review',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    switch (rating.toInt()) {
      case 5:
        return 'Excellent! 🌟';
      case 4:
        return 'Very Good! 👍';
      case 3:
        return 'Good 👌';
      case 2:
        return 'Fair 😐';
      case 1:
        return 'Poor 👎';
      default:
        return '';
    }
  }
}
