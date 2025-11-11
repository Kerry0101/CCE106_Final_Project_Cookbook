import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cookbook/models/recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';


String get userID => FirebaseAuth.instance.currentUser!.uid;

//create recipe
Future<void> createRecipe(Recipe recipe) async {
  final docRecipe = FirebaseFirestore.instance.collection('recipes').doc();
  recipe.recipeID = docRecipe.id;

  recipe.userID = userID;
  
  // Set initial moderation status
  recipe.status = 'pending';
  recipe.submittedAt = DateTime.now();

  final json = recipe.toJson();
  await docRecipe.set(json);
}

//read recipe
Stream<List<Recipe>> readRecipes({String? category}) {
  // Initial query to get approved recipes only (public view)
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('recipes')
      .where('status', isEqualTo: 'approved');

  // Apply category filter if provided and not 'All'
  if (category != null && category.isNotEmpty && category != 'All') {
    query = query.where('category', isEqualTo: category);
  }

  // Map the query snapshots to a list of Recipe objects
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Recipe.fromJson(doc.data());
    }).toList();
  });
}

//read user's own recipes (all statuses)
Stream<List<Recipe>> readMyRecipes({String? category}) {
  // Query to get recipes for the current user
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('recipes')
      .where('userID', isEqualTo: userID);

  // Apply category filter if provided and not 'All'
  if (category != null && category.isNotEmpty && category != 'All') {
    query = query.where('category', isEqualTo: category);
  }

  // Map the query snapshots to a list of Recipe objects
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Recipe.fromJson(doc.data());
    }).toList();
  });
}

//update recipe
Future<void> updateRecipe(Recipe recipe, String id) async {
  final docRecipe = FirebaseFirestore.instance.collection('recipes').doc(id);
  await docRecipe.update(recipe.toJson());
}

//delete recipe
Future<void> deleteRecipe(String id) async {
  final docRecipe = FirebaseFirestore.instance.collection('recipes').doc(id);
  await docRecipe.delete();
}

// count the number of recipes associated with the user
Future<num> countUserRecipes() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('recipes')
      .where('userID', isEqualTo: userID)
      .get();
  return querySnapshot.size;
}

//update isFavorite field
Future<void> updateIsFavorite(String recipeId, bool isFavorite) async {
  try {
    final docRecipe = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
    await docRecipe.update({'isFavorite': isFavorite});
  debugPrint('isFavorite updated successfully');
  } catch (e) {
  debugPrint('Error updating isFavorite: $e');
    // Handle error accordingly
  }
}

//read recipe favorites
Stream<List<Recipe>> readAllFavorites() {
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('recipes')
      .where('isFavorite', isEqualTo: true);

  return query.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Recipe.fromJson(doc.data())).toList());
}

//get user details
Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String userID) {
  DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userID);

  return userRef.snapshots();
}




