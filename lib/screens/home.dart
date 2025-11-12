import 'package:cookbook/services/firestore_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/screens/recipes/recipe_create.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/widgets/my_drawer.dart';
import 'package:cookbook/widgets/categories_lists.dart';
import 'package:cookbook/widgets/recipes_button.dart';
import 'package:cookbook/widgets/categories_dialog.dart';
import 'package:cookbook/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _uNameController = TextEditingController();
  String _selectedCategory = 'All';

  final ScrollController _homeScrollCtrl = ScrollController();
  final ScrollController _categoriesScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Culinary Chronicles",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      drawer: buildDrawer(context),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [bgc1, bgc2, bgc3, bgc4],
          ),
        ),
        child: Scrollbar(
          controller: _homeScrollCtrl,
          thumbVisibility: true,
          child: ListView(
            controller: _homeScrollCtrl,
            children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 16.0, bottom: 12.0),
            child: Text(
              "Categories",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 110, // Increased height to prevent overflow
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Scrollbar(
              controller: _categoriesScrollCtrl,
              thumbVisibility: false,
              thickness: 4,
              radius: const Radius.circular(10),
              child: ListView(
                controller: _categoriesScrollCtrl,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: [
                  // All Categories
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedCategory == 'All'
                                  ? const Color(0xFF008B8B)
                                  : Colors.grey[300],
                              border: _selectedCategory == 'All'
                                  ? Border.all(
                                      color: const Color(0xFF008B8B),
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: _selectedCategory == 'All'
                                      ? const Color(0xFF008B8B).withOpacity(0.4)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: _selectedCategory == 'All' ? 12 : 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.restaurant_menu,
                              color: _selectedCategory == 'All'
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 70,
                            child: Text(
                              'All',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: _selectedCategory == 'All'
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _selectedCategory == 'All'
                                    ? const Color(0xFF008B8B)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Appetizers.png",
                    labelText: "Appetizer",
                    isSelected: _selectedCategory == 'Appetizer',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Appetizer';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Breakfast.png",
                    labelText: "Breakfast",
                    isSelected: _selectedCategory == 'Breakfast',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Breakfast';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Lunch.png",
                    labelText: "Lunch",
                    isSelected: _selectedCategory == 'Lunch',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Lunch';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Dinner.png",
                    labelText: "Dinner",
                    isSelected: _selectedCategory == 'Dinner',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Dinner';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Dessert.png",
                    labelText: "Dessert",
                    isSelected: _selectedCategory == 'Dessert',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Dessert';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Snack.png",
                    labelText: "Snack",
                    isSelected: _selectedCategory == 'Snack',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Snack';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Beverage.png",
                    labelText: "Beverage",
                    isSelected: _selectedCategory == 'Beverage',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Beverage';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Soup.png",
                    labelText: "Soup",
                    isSelected: _selectedCategory == 'Soup',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Soup';
                      });
                    },
                  ),
                  CategoriesList(
                    imageUrl: "lib/images/categories/Salad.png",
                    labelText: "Salad",
                    isSelected: _selectedCategory == 'Salad',
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Salad';
                      });
                    },
                  ),
                  // More Button (11th item - last category "Main Course" moved to dialog)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => CategoriesDialog(
                          currentCategory: _selectedCategory,
                          onCategorySelected: (category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.grey[600],
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 70,
                            child: Text(
                              'More',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _uNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search recipes...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _uNameController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _uNameController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear, color: Colors.grey),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Recipes header with dynamic count
          StreamBuilder<List<Recipe>>(
            stream: readRecipes(category: _selectedCategory),
            builder: (context, countSnapshot) {
              int recipeCount = 0;
              if (countSnapshot.hasData) {
                final recipes = countSnapshot.data ?? [];
                // Count recipes matching search query
                recipeCount = recipes.where((recipe) {
                  if (_uNameController.text.isEmpty) return true;
                  return recipe.name.toLowerCase().contains(
                    _uNameController.text.toLowerCase(),
                  );
                }).length;
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'RECIPES ($recipeCount)',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          StreamBuilder<List<Recipe>>(
            stream: readRecipes(category: _selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final recipes = snapshot.data ?? const <Recipe>[];
              
              if (recipes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recipes yet',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to create your first recipe!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // IMPORTANT: this inner ListView must not scroll; let the outer ListView scroll.
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    if (_uNameController.text.isEmpty ||
                        recipe.name.toLowerCase().contains(
                          _uNameController.text.toLowerCase(),
                        )) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: RecipesButton(recipe: recipe),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 80), // Extra space for FAB
        ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const recipeCreate(),
            ),
          );
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Recipe',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeScrollCtrl.dispose();
    _categoriesScrollCtrl.dispose();
    _uNameController.dispose();
    super.dispose();
  }

}
