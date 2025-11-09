import 'package:cookbook/services/firestore_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/screens/recipes/recipe_create.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/widgets/my_drawer.dart';
import 'package:cookbook/widgets/categories_lists.dart';
import 'package:cookbook/widgets/recipes_button.dart';
import 'package:cookbook/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _uNameController = TextEditingController();
  num userRecipeCount = 0;
  String _selectedCategory = 'All';

    final ScrollController _homeScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _getUserRecipeCount();
  }

  Future<void> _getUserRecipeCount() async {
    userRecipeCount = await countUserRecipes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Culinary Chronicles",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: buildDrawer(context),
      body: Scrollbar(
        controller: _homeScrollCtrl,
        thumbVisibility: true,
        child: ListView(
          controller: _homeScrollCtrl,
          children: [
          Container(
            color: p_color,
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 20),
                    child: Text(
                      "Categories",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: p_color,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CategoriesList(
                      imageUrl: "lib/images/categories/Appetizers.png",
                      labelText: "Appetizer",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Breakfast.png",
                      labelText: "Breakfast",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Lunch.png",
                      labelText: "Lunch",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Dinner.png",
                      labelText: "Dinner",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Dessert.png",
                      labelText: "Dessert",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Snack.png",
                      labelText: "Snack",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Beverage.png",
                      labelText: "Beverage",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Soup.png",
                      labelText: "Soup",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/Salad.png",
                      labelText: "Salad",
                    ),
                    CategoriesList(
                      imageUrl: "lib/images/categories/MainCourse.png",
                      labelText: "MainCourse",
                    ),

                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextFormField(
              controller: _uNameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Search...',
                suffixIcon: IconButton(
                  onPressed: () {
                    _uNameController.clear();
                  },
                  icon: const Icon(Icons.search),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 8, 30, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECIPES ($userRecipeCount) ',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            items: <String>[
                              'All',
                              'Appetizer',
                              'Breakfast',
                              'Lunch',
                              'Dinner',
                              'Dessert',
                              'Snack',
                              'Beverage',
                              'Soup',
                              'Salad',
                              'Main Course',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue ?? 'All';
                              });
                            },
                            value: _selectedCategory,
                            underline: Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const recipeCreate(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            iconSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          

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
                    child: Text(
                      'No recipes yet. Create one now!',
                      style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                );
              }

              // IMPORTANT: this inner ListView must not scroll; let the outer ListView scroll.
              return ListView.builder(
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
                      padding: const EdgeInsets.all(8.0),
                      child: RecipesButton(recipe: recipe),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeScrollCtrl.dispose();
    _uNameController.dispose();
    super.dispose();
  }

}
