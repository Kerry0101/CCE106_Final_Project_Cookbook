import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cookbook/models/shopping_lists.dart';
import 'package:cookbook/utils/colors.dart';

class ShoppingLists extends StatefulWidget {
  const ShoppingLists({super.key});

  @override
  _ShoppingListsState createState() => _ShoppingListsState();
}

class _ShoppingListsState extends State<ShoppingLists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Shopping List',
          style: GoogleFonts.lato(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<List<ShoppingList>>(
        stream: readShoppingLists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<ShoppingList>? items = snapshot.data;
            if (items!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_basket_rounded,
                      size: 50,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No items yet',
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
              itemCount: items.length,
              itemBuilder: (context, index) {
                final shoppingItem = items[index];
                return ListTile(
                  leading: Checkbox(
                    value: shoppingItem.isChecked,
                    onChanged: (bool? value) {
                      shoppingItem.isChecked = value ?? false;
                      updateShoppingList(shoppingItem, shoppingItem.itemID);
                    },
                  ),
                  title: Text(
                    '${shoppingItem.itemName} (${shoppingItem.quantity})',
                    style: TextStyle(
                      decoration: shoppingItem.isChecked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete item?"),
                            content: const Text(
                                "Are you sure you want to delete this item?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteShoppingList(shoppingItem.itemID);
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addItemDialog(context);
        },
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _addItemDialog(BuildContext context) {
    String newItem = '';
    String newQty = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => newItem = value,
                decoration: const InputDecoration(hintText: 'Enter name'),
              ),
              TextField(
                onChanged: (value) => newQty = value,
                decoration: const InputDecoration(hintText: 'Enter quantity'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newItem.isNotEmpty) {
                  createShoppingList(ShoppingList(
                    userID: userID,
                    itemName: newItem,
                    isChecked: false,
                    quantity: newQty,
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
