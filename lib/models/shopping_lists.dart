import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingList {
  String itemID;
  String userID;
  final String itemName;
  bool isChecked;
  final String quantity;

  ShoppingList({
    this.itemID = '',
    required this.userID,
    required this.itemName,
    required this.isChecked,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'userID': userID,
      'itemName': itemName,
      'isChecked': isChecked,
      'quantity': quantity,

    };
  }

  static ShoppingList fromJson(Map<String, dynamic> json) => ShoppingList(
    itemID: json['itemID'],
    userID: json['userID'],
    itemName: json['itemName'],
    isChecked: json['isChecked'],
    quantity: json['quantity'],
  );
}

String userID = FirebaseAuth.instance.currentUser!.uid;

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
