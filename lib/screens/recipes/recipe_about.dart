import 'package:cookbook/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/screens/recipes/recipe_edit.dart';
import 'package:cookbook/services/firestore_functions.dart';
import 'package:cookbook/services/role_service.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/widgets/recipe_reviews_page.dart';

class RecipeAbout extends StatefulWidget {
  final Recipe recipe;

  const RecipeAbout({super.key, required this.recipe});

  @override
  State<RecipeAbout> createState() => _RecipeAboutState();
}

class _RecipeAboutState extends State<RecipeAbout> with SingleTickerProviderStateMixin {
  Utils utils = Utils();
  late TabController _tabController;
  bool _canEditDelete = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = await RoleService.isAdmin();
    
    setState(() {
      // User can edit/delete if they own the recipe OR they are an admin
      _canEditDelete = (currentUserId == widget.recipe.userID) || isAdmin;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.recipe.name,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          iconTheme: IconThemeData(
            color: primaryColor,
          ),
          actions: [
            // Only show menu if user has permission to edit/delete
            if (_canEditDelete)
              PopupMenuButton<String>(
                onSelected: (String choice) {
                  switch (choice) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => recipeEdit(
                            recipe: widget.recipe,
                          ),
                        ),
                      );
                      break;
                    case 'delete':
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete recipe?"),
                            content: const Text(
                                "Are you sure you want to delete this recipe?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  try {
                                    deleteRecipe(widget.recipe.recipeID);
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                    utils.showSnackBar(
                                        'Recipe has been deleted.', Colors.green);
                                  } catch (e) {
                                    utils.showSnackBar(
                                        'An error occurred. Please try again later.',
                                        Colors.red);
                                  }
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                child: Text(
                  'About',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Recipe',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
              ),
              Tab(
                child: Text(
                  'Reviews',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [bgc1, bgc2, bgc3, bgc4],
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Recipe Image
                  if (widget.recipe.imageUrl != null &&
                      widget.recipe.imageUrl!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 250,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image not available',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  // Rating Summary - Tappable to go to Reviews tab (moved above recipe name)
                  GestureDetector(
                    onTap: () {
                      _tabController.animateTo(2); // Navigate to Reviews tab (now index 2)
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[700],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.recipe.reviewCount > 0
                                ? widget.recipe.rating.toStringAsFixed(1)
                                : 'No ratings yet',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          if (widget.recipe.reviewCount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(${_formatReviewCount(widget.recipe.reviewCount)}) ${widget.recipe.reviewCount == 1 ? 'rating' : 'ratings'}',
                              style: GoogleFonts.lato(
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
                        child: Text(
                          widget.recipe.name,
                          style: GoogleFonts.lato(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                        child: Text(
                          widget.recipe.category,
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 8, 4),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: primaryColor,
                          ),
                          child: Text(
                            widget.recipe.tag,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Preparation Time: ${widget.recipe.prepTime} mins',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Cooking Time: ${widget.recipe.cookingTime} mins',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Total Time: ${widget.recipe.totalTime}',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Combined Recipe Tab (Ingredients + Directions)
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 5),
                    child: Text(
                      "Ingredients",
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.recipe.ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            "• $ingredient",
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(
                      thickness: 2,
                      color: primaryColor.withOpacity(0.3),
                    ),
                  ),
                  // Directions Section
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 5),
                    child: Text(
                      "Directions",
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.recipe.directions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.recipe.directions[index],
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Reviews Tab
            _buildReviewsTab(),
          ],
        ),
        ),
      ),
    );
  }

  // Helper function to format review count (1.2k, 350, etc.)
  String _formatReviewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  // Build the Reviews tab content
  Widget _buildReviewsTab() {
    return RecipeReviewsPage(
      recipeId: widget.recipe.recipeID,
      recipeOwnerId: widget.recipe.userID,
      currentRating: widget.recipe.rating,
      reviewCount: widget.recipe.reviewCount,
    );
  }
}
