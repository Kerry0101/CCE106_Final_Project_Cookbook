import 'package:flutter/material.dart';
import 'package:cookbook/services/moderation_service.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/widgets/admin_guard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModerateRecipesPage extends StatefulWidget {
  const ModerateRecipesPage({super.key});

  @override
  State<ModerateRecipesPage> createState() => _ModerateRecipesPageState();
}

class _ModerateRecipesPageState extends State<ModerateRecipesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _availableCategories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snack',
    'Beverage',
    'Appetizer',
    'Soup',
    'Salad',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Review Recipes',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Pending', icon: Icon(Icons.hourglass_empty)),
              Tab(text: 'Approved', icon: Icon(Icons.check_circle)),
              Tab(text: 'Rejected', icon: Icon(Icons.cancel)),
            ],
            labelColor: textColor1,
            unselectedLabelColor: textColor1.withOpacity(0.5),
            indicatorColor: bgc1,
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgc1, bgc2, bgc3, bgc4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPendingTab(),
            _buildApprovedTab(),
            _buildRejectedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingTab() {
    return StreamBuilder<List<Recipe>>(
      stream: ModerationService.pendingRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final recipes = snapshot.data ?? [];

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: textColor1.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No pending recipes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: recipes.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return _buildRecipeCard(recipes[index], isPending: true);
          },
        );
      },
    );
  }

  Widget _buildApprovedTab() {
    return StreamBuilder<List<Recipe>>(
      stream: ModerationService.approvedRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final recipes = snapshot.data ?? [];

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: textColor1.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No approved recipes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: recipes.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return _buildRecipeCard(recipes[index], isPending: false);
          },
        );
      },
    );
  }

  Widget _buildRejectedTab() {
    return StreamBuilder<List<Recipe>>(
      stream: ModerationService.rejectedRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final recipes = snapshot.data ?? [];

        if (recipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel_outlined, size: 64, color: textColor1.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No rejected recipes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: textColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: recipes.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return _buildRecipeCard(recipes[index], isPending: false);
          },
        );
      },
    );
  }

  Widget _buildRecipeCard(Recipe recipe, {required bool isPending}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Image
            if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),

            // Recipe Title
            Text(
              recipe.name,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor1,
              ),
            ),
            const SizedBox(height: 4),

            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bgc2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                recipe.category,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textColor1,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Time info
            Row(
              children: [
                Icon(Icons.timer, size: 14, color: textColor1.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text(
                  'Prep: ${recipe.prepTime} | Cook: ${recipe.cookingTime}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textColor1.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Submitted Date
            if (recipe.submittedAt != null)
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: textColor1.withOpacity(0.5)),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted: ${DateFormat('MMM dd, yyyy').format(recipe.submittedAt!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textColor1.withOpacity(0.5),
                    ),
                  ),
                ],
              ),

            // Approved/Rejected Info
            if (!isPending) ...[
              const SizedBox(height: 4),
              if (recipe.approvedAt != null)
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Approved: ${DateFormat('MMM dd, yyyy').format(recipe.approvedAt!)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              if (recipe.rejectionReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cancel, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Reason: ${recipe.rejectionReason}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],

            // Action Buttons (only for pending)
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(recipe),
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(recipe),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(Recipe recipe) {
    String? selectedCategory = recipe.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Approve Recipe',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a category for "${recipe.name}"',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedCategory != null) {
                  try {
                    final adminUid = FirebaseAuth.instance.currentUser!.uid;
                    await ModerationService.approveRecipe(
                      recipe.recipeID,
                      selectedCategory!,
                      adminUid,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Recipe approved as $selectedCategory'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Recipe recipe) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reject Recipe',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Provide a reason for rejecting "${recipe.name}"',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                final adminUid = FirebaseAuth.instance.currentUser!.uid;
                await ModerationService.rejectRecipe(
                  recipe.recipeID,
                  reasonController.text.trim(),
                  adminUid,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recipe rejected'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
