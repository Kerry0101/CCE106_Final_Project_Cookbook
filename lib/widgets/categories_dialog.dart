import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/widgets/suggest_category_dialog.dart';

class CategoriesDialog extends StatefulWidget {
  final String currentCategory;
  final Function(String) onCategorySelected;

  const CategoriesDialog({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoriesDialog> createState() => _CategoriesDialogState();
}

class _CategoriesDialogState extends State<CategoriesDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _allCategories = [
    {'name': 'All', 'icon': 'restaurant_menu'},
    {'name': 'Appetizer', 'image': 'lib/images/categories/Appetizers.png'},
    {'name': 'Breakfast', 'image': 'lib/images/categories/Breakfast.png'},
    {'name': 'Lunch', 'image': 'lib/images/categories/Lunch.png'},
    {'name': 'Dinner', 'image': 'lib/images/categories/Dinner.png'},
    {'name': 'Dessert', 'image': 'lib/images/categories/Dessert.png'},
    {'name': 'Snack', 'image': 'lib/images/categories/Snack.png'},
    {'name': 'Beverage', 'image': 'lib/images/categories/Beverage.png'},
    {'name': 'Soup', 'image': 'lib/images/categories/Soup.png'},
    {'name': 'Salad', 'image': 'lib/images/categories/Salad.png'},
    {'name': 'Main Course', 'image': 'lib/images/categories/MainCourse.png'},
  ];

  List<Map<String, String>> get _filteredCategories {
    if (_searchQuery.isEmpty) {
      return _allCategories;
    }
    return _allCategories.where((category) {
      return category['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Categories',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // Categories Grid
            Expanded(
              child: _filteredCategories.isEmpty
                  ? Center(
                      child: Text(
                        'No categories found',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = _filteredCategories[index];
                        final isSelected = category['name'] == widget.currentCategory;
                        
                        return GestureDetector(
                          onTap: () {
                            widget.onCategorySelected(category['name']!);
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Category Icon/Image
                                if (category.containsKey('icon'))
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey[300],
                                    ),
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      size: 25,
                                    ),
                                  )
                                else
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: primaryColor,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        category['image']!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                // Category Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    category['name']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            
            // New Category Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Close current dialog
                  showDialog(
                    context: context,
                    builder: (context) => const SuggestCategoryDialog(),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'New Category',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
