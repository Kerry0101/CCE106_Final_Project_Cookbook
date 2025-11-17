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
      extendBodyBehindAppBar: true,
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
      drawer: buildDrawer(context, currentRoute: '/home'),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [bgc1, bgc2, bgc3, bgc4],
          ),
        ),
        child: SafeArea(
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
            height: 120,
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
              child: StreamBuilder<List<String>>(
                stream: readCategories(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];
                  
                  // Define available icon images that will cycle
                  final categoryImages = [
                    'lib/images/categories/Appetizers.png',
                    'lib/images/categories/Breakfast.png',
                    'lib/images/categories/Lunch.png',
                    'lib/images/categories/Dinner.png',
                    'lib/images/categories/Dessert.png',
                    'lib/images/categories/Snack.png',
                    'lib/images/categories/Beverage.png',
                    'lib/images/categories/Soup.png',
                    'lib/images/categories/Salad.png',
                    'lib/images/categories/MainCourse.png',
                  ];
                  
                  // Map specific categories to their images
                  final specificImages = {
                    'Appetizer': 'lib/images/categories/Appetizers.png',
                    'Breakfast': 'lib/images/categories/Breakfast.png',
                    'Lunch': 'lib/images/categories/Lunch.png',
                    'Dinner': 'lib/images/categories/Dinner.png',
                    'Dessert': 'lib/images/categories/Dessert.png',
                    'Snack': 'lib/images/categories/Snack.png',
                    'Beverage': 'lib/images/categories/Beverage.png',
                    'Soup': 'lib/images/categories/Soup.png',
                    'Salad': 'lib/images/categories/Salad.png',
                    'Main Course': 'lib/images/categories/MainCourse.png',
                  };
                  
                  String getCategoryImage(String categoryName, int index) {
                    if (specificImages.containsKey(categoryName)) {
                      return specificImages[categoryName]!;
                    }
                    return categoryImages[index % categoryImages.length];
                  }
                  
                  // Take first 9 categories for horizontal list
                  final displayCategories = categories.take(9).toList();
                  
                  return ListView(
                    controller: _categoriesScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    children: [
                      // All Categories button
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
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  'All',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: _selectedCategory == 'All'
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: _selectedCategory == 'All'
                                        ? const Color(0xFF008B8B)
                                        : Colors.black87,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Dynamic categories
                      ...displayCategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return CategoriesList(
                          imageUrl: getCategoryImage(category, index),
                          labelText: category,
                          isSelected: _selectedCategory == category,
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        );
                      }),
                      
                      // More Button
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
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 72,
                                child: Text(
                                  'More',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const recipeCreate(),
              settings: const RouteSettings(name: '/create-recipe'),
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
