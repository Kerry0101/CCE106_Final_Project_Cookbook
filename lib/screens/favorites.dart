import 'package:cookbook/services/firestore_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/widgets/recipes_button.dart';
import 'package:cookbook/utils/colors.dart';

class FavoritesList extends StatefulWidget {
  const FavoritesList({super.key});

  @override
  State<FavoritesList> createState() => _FavoritesListState();
}

class _FavoritesListState extends State<FavoritesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Favourites',
          style: GoogleFonts.lato(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: readAllFavorites(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Recipe> recipes = snapshot.data ?? [];
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 50,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No favourites yet',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final Recipe recipe = recipes[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: RecipesButton(recipe: recipe),
              );
            },
          );
        },
      ),
    );
  }
}
