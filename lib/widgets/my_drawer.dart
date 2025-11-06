import 'dart:ui';
import 'package:cookbook/services/firestore_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/screens/favorites.dart';
import 'package:cookbook/screens/home.dart';
import 'package:cookbook/screens/recipes/recipe_create.dart';
import 'package:cookbook/screens/shopping_lists.dart';
import 'package:cookbook/utils/colors.dart';

Widget buildDrawer(BuildContext context) {
  return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: getUserDetails(userID),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Center(child: Text('User does not exist'));
      }

      String userName = snapshot.data?.get("name") ?? 'User Name';

      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: primaryColor,
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Image.asset(
                          'lib/images/sandwich.jpg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              leading: Icon(
                Icons.local_dining_rounded,
                color: primaryColor,
              ),
              title: Text(
                'My Recipes',
                style: GoogleFonts.lato(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add_rounded,
                color: primaryColor,
              ),
              title: Text(
                'Create a Recipe',
                style: GoogleFonts.lato(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const recipeCreate()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.shopping_basket_rounded,
                color: primaryColor,
              ),
              title: Text(
                'Shopping Lists',
                style: GoogleFonts.lato(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingLists()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.favorite,
                color: primaryColor,
              ),
              title: Text(
                'Favourites',
                style: GoogleFonts.lato(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoritesList()),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
