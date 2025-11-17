import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingList {
  String itemID;
  String userID;
  final String itemName;
  bool isChecked;
  final String quantity;
  final String? recipeID;
  final String? recipeName;
  final String? unit;
  final DateTime addedAt;

  ShoppingList({
    this.itemID = '',
    required this.userID,
    required this.itemName,
    required this.isChecked,
    required this.quantity,
    this.recipeID,
    this.recipeName,
    this.unit,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'userID': userID,
      'itemName': itemName,
      'isChecked': isChecked,
      'quantity': quantity,
      'recipeID': recipeID,
      'recipeName': recipeName,
      'unit': unit,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  static ShoppingList fromJson(Map<String, dynamic> json) => ShoppingList(
    itemID: json['itemID'] ?? '',
    userID: json['userID'] ?? '',
    itemName: json['itemName'] ?? '',
    isChecked: json['isChecked'] ?? false,
    quantity: json['quantity'] ?? '',
    recipeID: json['recipeID'],
    recipeName: json['recipeName'],
    unit: json['unit'],
    addedAt: json['addedAt'] != null 
        ? (json['addedAt'] as Timestamp).toDate() 
        : DateTime.now(),
  );
}

// Get current user ID dynamically (not cached as global variable)
String get userID => FirebaseAuth.instance.currentUser!.uid;

//create ShoppingList
Future<void> createShoppingList(ShoppingList shoppingList) async {
  final docShoppingLists= FirebaseFirestore.instance.collection('shoppingList').doc();
  shoppingList.itemID = docShoppingLists.id;

  shoppingList.userID = userID;

  final json = shoppingList.toJson();
  await docShoppingLists.set(json);
}

//read ShoppingList
Stream<List<ShoppingList>> readShoppingLists() {
  return FirebaseFirestore.instance
      .collection('shoppingList')
      .where('userID', isEqualTo: userID)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => ShoppingList.fromJson(doc.data())).toList());
}

//update ShoppingList
Future<void> updateShoppingList(ShoppingList shoppingList, String id) async {
  final docShoppingLists = FirebaseFirestore.instance.collection('shoppingList').doc(id);
  await docShoppingLists.update(shoppingList.toJson());
}

//delete ShoppingList
Future<void> deleteShoppingList(String id) async {
  final docShoppingLists = FirebaseFirestore.instance.collection('shoppingList').doc(id);
  await docShoppingLists.delete();
}

//add recipe ingredients to shopping list
Future<void> addRecipeToShoppingList(String recipeID, String recipeName, List<String> ingredients) async {
  final batch = FirebaseFirestore.instance.batch();
  
  for (String ingredient in ingredients) {
    // Parse ingredient to extract quantity and name
    // Format expected: "2 cups flour" or "1 egg" or "salt to taste"
    final parts = ingredient.trim().split(' ');
    String quantity = '';
    String unit = '';
    String itemName = ingredient;
    
    if (parts.length >= 2) {
      // Try to parse quantity
      final potentialQty = parts[0];
      if (double.tryParse(potentialQty) != null || 
          potentialQty.contains('/') || 
          potentialQty.toLowerCase() == 'a' ||
          potentialQty.toLowerCase() == 'an') {
        quantity = potentialQty;
        
        // Check if next part is a unit
        if (parts.length >= 3) {
          final potentialUnit = parts[1].toLowerCase();
          if (_isUnit(potentialUnit)) {
            unit = potentialUnit;
            itemName = parts.sublist(2).join(' ');
          } else {
            itemName = parts.sublist(1).join(' ');
          }
        } else {
          itemName = parts.sublist(1).join(' ');
        }
      }
    }
    
    final docRef = FirebaseFirestore.instance.collection('shoppingList').doc();
    final shoppingItem = ShoppingList(
      itemID: docRef.id,
      userID: userID,
      itemName: itemName,
      isChecked: false,
      quantity: quantity,
      unit: unit.isNotEmpty ? unit : null,
      recipeID: recipeID,
      recipeName: recipeName,
    );
    
    batch.set(docRef, shoppingItem.toJson());
  }
  
  await batch.commit();
}

// Helper function to check if a word is a measurement unit
bool _isUnit(String word) {
  final units = [
    'cup', 'cups', 'tablespoon', 'tablespoons', 'tbsp', 'tsp', 'teaspoon', 'teaspoons',
    'ounce', 'ounces', 'oz', 'pound', 'pounds', 'lb', 'lbs', 'gram', 'grams', 'g',
    'kilogram', 'kilograms', 'kg', 'milliliter', 'milliliters', 'ml', 'liter', 'liters', 'l',
    'piece', 'pieces', 'clove', 'cloves', 'slice', 'slices', 'pinch', 'dash', 'can', 'cans',
    'package', 'packages', 'box', 'boxes', 'jar', 'jars', 'bottle', 'bottles',
  ];
  return units.contains(word.toLowerCase());
}

//delete all items from a specific recipe
Future<void> deleteRecipeFromShoppingList(String recipeID) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('shoppingList')
      .where('userID', isEqualTo: userID)
      .where('recipeID', isEqualTo: recipeID)
      .get();
  
  final batch = FirebaseFirestore.instance.batch();
  for (var doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  
  await batch.commit();
}

//check if recipe is already in shopping list
Future<bool> isRecipeInShoppingList(String recipeID) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('shoppingList')
      .where('userID', isEqualTo: userID)
      .where('recipeID', isEqualTo: recipeID)
      .limit(1)
      .get();
  
  return snapshot.docs.isNotEmpty;
}
