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

//update isFavorite field - user-specific favorites
Future<void> updateIsFavorite(String recipeId, bool isFavorite) async {
  try {
    final currentUserId = userID;
    final userFavoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('favorites')
        .doc(recipeId);
    
    if (isFavorite) {
      // Add to favorites
      await userFavoriteRef.set({
        'recipeId': recipeId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Recipe added to user favorites');
    } else {
      // Remove from favorites
      await userFavoriteRef.delete();
      debugPrint('Recipe removed from user favorites');
    }
  } catch (e) {
    debugPrint('Error updating isFavorite: $e');
    // Handle error accordingly
  }
}

//read recipe favorites - user-specific
Stream<List<Recipe>> readAllFavorites() {
  final currentUserId = userID;
  
  // Get user's favorite recipe IDs
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('favorites')
      .snapshots()
      .asyncMap((favSnapshot) async {
    if (favSnapshot.docs.isEmpty) {
      return <Recipe>[];
    }
    
    // Get all favorite recipe IDs
    final favoriteIds = favSnapshot.docs.map((doc) => doc.id).toList();
    
    // Fetch all recipes that are in the favorites list
    final recipesSnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .where(FieldPath.documentId, whereIn: favoriteIds)
        .get();
    
    return recipesSnapshot.docs
        .map((doc) => Recipe.fromJson(doc.data()))
        .toList();
  });
}

//check if recipe is favorited by current user
Future<bool> isRecipeFavorited(String recipeId) async {
  try {
    final currentUserId = userID;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('favorites')
        .doc(recipeId)
        .get();
    
    return doc.exists;
  } catch (e) {
    debugPrint('Error checking if recipe is favorited: $e');
    return false;
  }
}

//stream to check if recipe is favorited by current user
Stream<bool> isRecipeFavoritedStream(String recipeId) {
  final currentUserId = userID;
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserId)
      .collection('favorites')
      .doc(recipeId)
      .snapshots()
      .map((doc) => doc.exists);
}

//get user details
Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String userID) {
  DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userID);

  return userRef.snapshots();
}

//submit category suggestion
Future<void> submitCategorySuggestion(String categoryName, String categoryDescription) async {
  try {
    // Check for duplicate category name (case-insensitive) with pending status
    final duplicateCheck = await FirebaseFirestore.instance
        .collection('category_suggestions')
        .where('suggestedBy', isEqualTo: userID)
        .where('status', isEqualTo: 'pending')
        .get();
    
    // Check if any pending suggestion has the same name (case-insensitive)
    final normalizedName = categoryName.toLowerCase().trim();
    for (var doc in duplicateCheck.docs) {
      final existingName = (doc.data()['categoryName'] as String).toLowerCase().trim();
      if (existingName == normalizedName) {
        throw Exception('duplicate_category');
      }
    }
    
    final docCategory = FirebaseFirestore.instance.collection('category_suggestions').doc();
    
    await docCategory.set({
      'id': docCategory.id,
      'categoryName': categoryName,
      'description': categoryDescription,
      'suggestedBy': userID,
      'status': 'pending', // 'pending', 'approved', 'rejected'
      'submittedAt': FieldValue.serverTimestamp(),
      'reviewedAt': null,
      'reviewedBy': null,
      'rejectionReason': null,
    });
    
    debugPrint('Category suggestion submitted successfully');
  } catch (e) {
    debugPrint('Error submitting category suggestion: $e');
    rethrow;
  }
}

//read all category suggestions (for admin)
Stream<List<Map<String, dynamic>>> readCategorySuggestions({String? status}) {
  Query<Map<String, dynamic>> query = FirebaseFirestore.instance
      .collection('category_suggestions')
      .orderBy('submittedAt', descending: true);
  
  if (status != null && status.isNotEmpty) {
    query = query.where('status', isEqualTo: status);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
}

//approve category suggestion
Future<void> approveCategorySuggestion(String suggestionId) async {
  try {
    final docCategory = FirebaseFirestore.instance
        .collection('category_suggestions')
        .doc(suggestionId);
    
    await docCategory.update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': userID,
    });
    
    debugPrint('Category suggestion approved');
  } catch (e) {
    debugPrint('Error approving category suggestion: $e');
    rethrow;
  }
}

//reject category suggestion
Future<void> rejectCategorySuggestion(String suggestionId, String reason) async {
  try {
    final docCategory = FirebaseFirestore.instance
        .collection('category_suggestions')
        .doc(suggestionId);
    
    await docCategory.update({
      'status': 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': userID,
      'rejectionReason': reason,
    });
    
    debugPrint('Category suggestion rejected');
  } catch (e) {
    debugPrint('Error rejecting category suggestion: $e');
    rethrow;
  }
}

//count pending category suggestions
Future<int> countPendingCategorySuggestions() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('category_suggestions')
        .where('status', isEqualTo: 'pending')
        .get();
    
    return snapshot.docs.length;
  } catch (e) {
    debugPrint('Error counting pending category suggestions: $e');
    return 0;
  }
}




