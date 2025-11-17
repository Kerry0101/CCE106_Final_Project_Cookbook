import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/models/shopping_lists.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/utils/utils.dart';

class ShoppingListGroupedView extends StatefulWidget {
  final List<ShoppingList> items;
  
  const ShoppingListGroupedView({super.key, required this.items});

  @override
  State<ShoppingListGroupedView> createState() => _ShoppingListGroupedViewState();
}

class _ShoppingListGroupedViewState extends State<ShoppingListGroupedView> {
  final Utils utils = Utils();
  final Map<String, bool> _expandedRecipes = {};

  Map<String, List<ShoppingList>> _groupByRecipe() {
    final Map<String, List<ShoppingList>> grouped = {};
    
    for (var item in widget.items) {
      final key = item.recipeID ?? 'manual';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByRecipe();
    final recipeKeys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: recipeKeys.length,
      itemBuilder: (context, index) {
        final key = recipeKeys[index];
        final recipeItems = grouped[key]!;
        final recipeName = recipeItems.first.recipeName ?? 'Manual Items';
        final isExpanded = _expandedRecipes[key] ?? true;
        final checkedCount = recipeItems.where((item) => item.isChecked).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Recipe Header
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _expandedRecipes[key] = !isExpanded;
                    });
                  },
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.vertical(
                        top: const Radius.circular(16),
                        bottom: isExpanded ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          key == 'manual' ? Icons.edit : Icons.restaurant_menu,
                          color: primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipeName,
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$checkedCount/${recipeItems.length} items checked',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (key != 'manual')
                          IconButton(
                            icon: Icon(Icons.delete_sweep, color: Colors.red[400]),
                            onPressed: () => _deleteRecipe(key, recipeName),
                            tooltip: 'Remove all items from this recipe',
                          ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Items List
              if (isExpanded)
                ...recipeItems.map((item) => _buildItemTile(item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemTile(ShoppingList item) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: item.isChecked,
          activeColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onChanged: (bool? value) {
            item.isChecked = value ?? false;
            updateShoppingList(item, item.itemID);
            setState(() {});
          },
        ),
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? Colors.black45 : Colors.black87,
            ),
            children: [
              if (item.quantity.isNotEmpty)
                TextSpan(
                  text: '${item.quantity} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (item.unit != null)
                TextSpan(
                  text: '${item.unit} ',
                  style: TextStyle(
                    color: item.isChecked ? Colors.black38 : Colors.black54,
                  ),
                ),
              TextSpan(text: item.itemName),
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
          onPressed: () => _deleteItem(item),
        ),
      ),
    );
  }

  void _deleteRecipe(String recipeID, String recipeName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Remove Recipe?',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Remove all ingredients from "$recipeName"?',
            style: GoogleFonts.lato(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await deleteRecipeFromShoppingList(recipeID);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  utils.showSuccess('Recipe removed from shopping list');
                } catch (e) {
                  utils.showError('Failed to remove recipe');
                }
              },
              child: Text(
                'Remove',
                style: GoogleFonts.lato(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(ShoppingList item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete item?',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${item.itemName}"?',
            style: GoogleFonts.lato(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                try {
                  deleteShoppingList(item.itemID);
                  Navigator.of(context).pop();
                  utils.showSuccess('Item has been deleted');
                } catch (error) {
                  utils.showError('An error occurred. Please try again later.');
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.lato(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
