import 'package:cookbook/services/firestore_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/widgets/my_drawer.dart';
import 'package:cookbook/widgets/recipes_button.dart';
import 'package:cookbook/utils/colors.dart';

class MyRecipesPage extends StatefulWidget {
  const MyRecipesPage({super.key});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Scaffold(
      drawer: buildDrawer(context, currentRoute: '/my-recipes'),
      appBar: AppBar(
        title: Text(
          'My Recipes',
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
      body: StreamBuilder<List<Recipe>>(
        stream: readMyRecipes(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipes = snapshot.data ?? [];
          final pendingRecipes = recipes.where((r) => r.status == 'pending').toList();
          final approvedRecipes = recipes.where((r) => r.status == 'approved').toList();
          final rejectedRecipes = recipes.where((r) => r.status == 'rejected').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPendingTab(pendingRecipes),
              _buildApprovedTab(approvedRecipes),
              _buildRejectedTab(rejectedRecipes),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPendingTab(List<Recipe> pendingRecipes) {
    if (pendingRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: textColor1.withOpacity(0.3),
            ),
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
      itemCount: pendingRecipes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: RecipesButton(recipe: pendingRecipes[index]),
        );
      },
    );
  }

  Widget _buildApprovedTab(List<Recipe> approvedRecipes) {
    if (approvedRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: textColor1.withOpacity(0.3),
            ),
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
      itemCount: approvedRecipes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: RecipesButton(recipe: approvedRecipes[index]),
        );
      },
    );
  }

  Widget _buildRejectedTab(List<Recipe> rejectedRecipes) {
    if (rejectedRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_outlined,
              size: 64,
              color: textColor1.withOpacity(0.3),
            ),
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
      itemCount: rejectedRecipes.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Column(
            children: [
              RecipesButton(recipe: rejectedRecipes[index]),
              if (rejectedRecipes[index].rejectionReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reason: ${rejectedRecipes[index].rejectionReason}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
