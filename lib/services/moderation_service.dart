import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookbook/models/recipe.dart';

class ModerationService {
  // Stream of pending recipes
  static Stream<List<Recipe>> pendingRecipes() {
    return FirebaseFirestore.instance
        .collection('recipes')
        .where('status', isEqualTo: 'pending')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList());
  }

  // Stream of approved recipes
  static Stream<List<Recipe>> approvedRecipes() {
    return FirebaseFirestore.instance
        .collection('recipes')
        .where('status', isEqualTo: 'approved')
        .orderBy('approvedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList());
  }

  // Stream of rejected recipes
  static Stream<List<Recipe>> rejectedRecipes() {
    return FirebaseFirestore.instance
        .collection('recipes')
        .where('status', isEqualTo: 'rejected')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Recipe.fromJson(doc.data()))
            .toList());
  }

  // Approve a recipe
  static Future<void> approveRecipe(
      String recipeId, String category, String adminUid) async {
    // Fetch recipe to check author
    final recipeDoc = await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .get();
    
    final authorUid = recipeDoc.data()?['userID'];
    
    // Prevent self-approval
    if (authorUid == adminUid) {
      throw Exception('You cannot approve your own recipes. Another admin must approve them.');
    }
    
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .update({
      'status': 'approved',
      'category': category,
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': adminUid,
      'rejectionReason': null,
    });
  }

  // Reject a recipe
  static Future<void> rejectRecipe(
      String recipeId, String reason, String adminUid) async {
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(recipeId)
        .update({
      'status': 'rejected',
      'approvedAt': null,
      'approvedBy': adminUid,
      'rejectionReason': reason,
    });
  }

  // Get count of pending recipes as a Stream
  static Stream<int> getPendingCount() {
    return FirebaseFirestore.instance
        .collection('recipes')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
