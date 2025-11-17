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
import 'package:cookbook/screens/my_reviews_page.dart';
import 'package:cookbook/screens/recipes/recipe_create.dart';
import 'package:cookbook/screens/shopping_lists.dart';
import 'package:cookbook/screens/admin/moderate_recipes_page.dart';
import 'package:cookbook/screens/admin/review_categories.dart';
import 'package:cookbook/screens/profile/profile_page.dart';
import 'package:cookbook/screens/profile/admin_profile_management.dart';
import 'package:cookbook/utils/colors.dart';

Widget buildDrawer(BuildContext context, {String? currentRoute}) {
  // Determine current route from the widget tree if not explicitly provided
  String? route = currentRoute;
  if (route == null) {
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null && modalRoute.settings.name != null) {
      route = modalRoute.settings.name;
    }
  }
  
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

      final userData = snapshot.data!.data();
      String userName = userData?['displayName'] ?? userData?['name'] ?? 'User';
      String? photoURL = userData?['photoURL'];

      return Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgc1, bgc2, bgc3, bgc4],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: primaryColor,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: photoURL != null && photoURL.isNotEmpty
                            ? NetworkImage(photoURL)
                            : null,
                        child: photoURL == null || photoURL.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: primaryColor,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        userName,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ListTile(
              selected: route == '/profile',
              selectedTileColor: primaryColor.withOpacity(0.1),
              leading: Icon(
                Icons.person,
                color: route == '/profile' ? primaryColor : primaryColor.withOpacity(0.7),
              ),
              title: Text(
                'My Profile',
                style: GoogleFonts.lato(
                  fontWeight: route == '/profile' ? FontWeight.w700 : FontWeight.w600,
                  color: route == '/profile' ? primaryColor : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                    settings: const RouteSettings(name: '/profile'),
                  ),
                );
              },
            ),
            ListTile(
              selected: route == '/home',
              selectedTileColor: primaryColor.withOpacity(0.1),
              leading: Icon(
                Icons.home,
                color: route == '/home' ? primaryColor : primaryColor.withOpacity(0.7),
              ),
              title: Text(
                'Home',
                style: GoogleFonts.lato(
                  fontWeight: route == '/home' ? FontWeight.w700 : FontWeight.w400,
                  color: route == '/home' ? primaryColor : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                    settings: const RouteSettings(name: '/home'),
                  ),
                );
              },
            ),
            ListTile(
              selected: route == '/my-recipes',
              selectedTileColor: primaryColor.withOpacity(0.1),
              leading: Icon(
                Icons.local_dining_rounded,
                color: route == '/my-recipes' ? primaryColor : primaryColor.withOpacity(0.7),
              ),
              title: Text(
                'My Recipes',
                style: GoogleFonts.lato(
                  fontWeight: route == '/my-recipes' ? FontWeight.w700 : FontWeight.w400,
                  color: route == '/my-recipes' ? primaryColor : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRecipesPage(),
                    settings: const RouteSettings(name: '/my-recipes'),
                  ),
                );
              },
            ),
            ListTile(
              selected: route == '/my-reviews',
              selectedTileColor: primaryColor.withOpacity(0.1),
              leading: Icon(
                Icons.rate_review,
                color: route == '/my-reviews' ? primaryColor : primaryColor.withOpacity(0.7),
              ),
              title: Text(
                'My Reviews',
                style: GoogleFonts.lato(
                  fontWeight: route == '/my-reviews' ? FontWeight.w700 : FontWeight.w400,
                  color: route == '/my-reviews' ? primaryColor : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyReviewsPage(),
                    settings: const RouteSettings(name: '/my-reviews'),
                  ),
                );
              },
            ),
            ListTile(
              selected: route == '/create-recipe',
              selectedTileColor: primaryColor.withOpacity(0.1),
              leading: Icon(
                Icons.add_rounded,
                color: route == '/create-recipe' ? primaryColor : primaryColor.withOpacity(0.7),
              ),
              title: Text(
                'Create a Recipe',
                style: GoogleFonts.lato(
                  fontWeight: route == '/create-recipe' ? FontWeight.w700 : FontWeight.w400,
                  color: route == '/create-recipe' ? primaryColor : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const recipeCreate(),
                    settings: const RouteSettings(name: '/create-recipe'),
                  ),
                );
              },
            ),
            ListTile(
              selected: route == '/shopping-lists',
              selectedTileColor: primaryColor.withOpacity(0.1),
              leading: Icon(
                Icons.shopping_basket_rounded,
                color: route == '/shopping-lists' ? primaryColor : primaryColor.withOpacity(0.7),
              ),
              title: Text(
                'Shopping List',
                style: GoogleFonts.lato(
                  fontWeight: route == '/shopping-lists' ? FontWeight.w700 : FontWeight.w400,
                  color: route == '/shopping-lists' ? primaryColor : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShoppingLists(),
                    settings: const RouteSettings(name: '/shopping-lists'),
                  ),
                );
              },
            ),
            ListTile(
              selected: route == '/favorites',
              selectedTileColor: primaryColor.withOpacity(0.1),
              leading: Icon(
                Icons.favorite,
                color: route == '/favorites' ? primaryColor : primaryColor.withOpacity(0.7),
              ),
              title: Text(
                'Favorites',
                style: GoogleFonts.lato(
                  fontWeight: route == '/favorites' ? FontWeight.w700 : FontWeight.w400,
                  color: route == '/favorites' ? primaryColor : Colors.black87,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesList(),
                    settings: const RouteSettings(name: '/favorites'),
                  ),
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
                        selected: route == '/admin-users',
                        selectedTileColor: primaryColor.withOpacity(0.1),
                        leading: Icon(
                          Icons.manage_accounts,
                          color: route == '/admin-users' ? primaryColor : primaryColor.withOpacity(0.7),
                        ),
                        title: Text(
                          'User Management',
                          style: GoogleFonts.lato(
                            fontWeight: route == '/admin-users' ? FontWeight.w700 : FontWeight.w400,
                            color: route == '/admin-users' ? primaryColor : Colors.black87,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminProfileManagement(),
                              settings: const RouteSettings(name: '/admin-users'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        selected: route == '/admin-review-recipes',
                        selectedTileColor: primaryColor.withOpacity(0.1),
                        leading: Icon(
                          Icons.admin_panel_settings,
                          color: route == '/admin-review-recipes' ? primaryColor : primaryColor.withOpacity(0.7),
                        ),
                        title: Text(
                          'Review Recipes',
                          style: GoogleFonts.lato(
                            fontWeight: route == '/admin-review-recipes' ? FontWeight.w700 : FontWeight.w400,
                            color: route == '/admin-review-recipes' ? primaryColor : Colors.black87,
                          ),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ModerateRecipesPage(),
                              settings: const RouteSettings(name: '/admin-review-recipes'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        selected: route == '/admin-review-categories',
                        selectedTileColor: primaryColor.withOpacity(0.1),
                        leading: Icon(
                          Icons.category,
                          color: route == '/admin-review-categories' ? primaryColor : primaryColor.withOpacity(0.7),
                        ),
                        title: Text(
                          'Review Categories',
                          style: GoogleFonts.lato(
                            fontWeight: route == '/admin-review-categories' ? FontWeight.w700 : FontWeight.w400,
                            color: route == '/admin-review-categories' ? primaryColor : Colors.black87,
                          ),
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReviewCategoriesScreen(),
                              settings: const RouteSettings(name: '/admin-review-categories'),
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
        ),
      );
    },
  );
}
