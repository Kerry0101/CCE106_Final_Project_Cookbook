import 'dart:ui';
import 'package:cookbook/services/firestore_functions.dart';
import 'package:cookbook/services/role_service.dart';
import 'package:cookbook/services/moderation_service.dart';
import 'package:cookbook/utils/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/screens/favorites.dart';
import 'package:cookbook/screens/home.dart';
import 'package:cookbook/screens/my_recipes_page.dart';
import 'package:cookbook/screens/recipes/recipe_create.dart';
import 'package:cookbook/screens/shopping_lists.dart';
import 'package:cookbook/screens/admin/moderate_recipes_page.dart';
import 'package:cookbook/screens/admin/review_categories.dart';
import 'package:cookbook/screens/profile/profile_page.dart';
import 'package:cookbook/screens/profile/admin_profile_management.dart';
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
                Icons.person,
                color: primaryColor,
              ),
              title: Text(
                'My Profile',
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            Divider(color: primaryColor.withOpacity(0.2), height: 1),
            ListTile(
              leading: Icon(
                Icons.search,
                color: primaryColor,
              ),
              title: Text(
                'Browse All Recipes',
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
                  MaterialPageRoute(builder: (context) => const MyRecipesPage()),
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
            // Admin-only menu items
            StreamBuilder<String>(
              stream: RoleService.roleStream(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.hasData && roleSnapshot.data == 'admin') {
                  return Column(
                    children: [
                      Divider(color: primaryColor.withOpacity(0.3)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ADMIN',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.manage_accounts,
                          color: primaryColor,
                        ),
                        title: Text(
                          'User Management',
                          style: GoogleFonts.lato(),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminProfileManagement(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.admin_panel_settings,
                          color: primaryColor,
                        ),
                        title: Text(
                          'Review Recipes',
                          style: GoogleFonts.lato(),
                        ),
                        trailing: StreamBuilder<int>(
                          stream: ModerationService.getPendingCount(),
                          builder: (context, countSnapshot) {
                            if (countSnapshot.hasData && countSnapshot.data! > 0) {
                              return Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${countSnapshot.data}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ModerateRecipesPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.category,
                          color: primaryColor,
                        ),
                        title: Text(
                          'Review Categories',
                          style: GoogleFonts.lato(),
                        ),
                        trailing: StreamBuilder<int>(
                          stream: countPendingCategorySuggestions().asStream(),
                          builder: (context, countSnapshot) {
                            if (countSnapshot.hasData && countSnapshot.data! > 0) {
                              return Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${countSnapshot.data}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReviewCategoriesScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(color: primaryColor.withOpacity(0.3)),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: primaryColor,
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.lato(),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                confirmLogout(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
