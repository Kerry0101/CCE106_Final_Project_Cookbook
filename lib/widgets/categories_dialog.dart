import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/widgets/suggest_category_dialog.dart';
import 'package:cookbook/services/firestore_functions.dart';

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

  final List<String> _categoryImagePaths = [
    'lib/images/categories/Appetizers.png',
    'lib/images/categories/Breakfast.png',
    'lib/images/categories/Lunch.png',
    'lib/images/categories/Dinner.png',
    'lib/images/categories/Dessert.png',
    'lib/images/categories/Snack.png',
    'lib/images/categories/Beverage.png',
    'lib/images/categories/Soup.png',
    'lib/images/categories/Salad.png',
    'lib/images/categories/MainCourse.png',
  ];

  final Map<String, String> _categoryImages = {
    'Appetizer': 'lib/images/categories/Appetizers.png',
    'Breakfast': 'lib/images/categories/Breakfast.png',
    'Lunch': 'lib/images/categories/Lunch.png',
    'Dinner': 'lib/images/categories/Dinner.png',
    'Dessert': 'lib/images/categories/Dessert.png',
    'Snack': 'lib/images/categories/Snack.png',
    'Beverage': 'lib/images/categories/Beverage.png',
    'Soup': 'lib/images/categories/Soup.png',
    'Salad': 'lib/images/categories/Salad.png',
    'Main Course': 'lib/images/categories/MainCourse.png',
  };

  String _getCategoryImage(String categoryName, int index) {
    // First check if there's a predefined image for this category
    if (_categoryImages.containsKey(categoryName)) {
      return _categoryImages[categoryName]!;
    }
    // Otherwise, cycle through available images based on index
    final imageIndex = index % _categoryImagePaths.length;
    return _categoryImagePaths[imageIndex];
  }

  List<String> _filterCategories(List<String> categories) {
    if (_searchQuery.isEmpty) {
      return categories;
    }
    return categories.where((category) {
      return category.toLowerCase().contains(_searchQuery.toLowerCase());
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
              child: StreamBuilder<List<String>>(
                stream: readCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading categories',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  final allCategories = snapshot.data ?? [];
                  // Add "All" to the beginning
                  final categoriesWithAll = ['All', ...allCategories];
                  final filteredCategories = _filterCategories(categoriesWithAll);

                  if (filteredCategories.isEmpty) {
                    return Center(
                      child: Text(
                        'No categories found',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final categoryName = filteredCategories[index];
                      final isSelected = categoryName == widget.currentCategory;
                      
                      return GestureDetector(
                        onTap: () {
                          widget.onCategorySelected(categoryName);
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
                              if (categoryName == 'All')
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
                                      _getCategoryImage(categoryName, index),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback icon if image not found
                                        return Container(
                                          color: isSelected
                                              ? primaryColor
                                              : primaryColor.withOpacity(0.2),
                                          child: Icon(
                                            Icons.category,
                                            color: isSelected
                                                ? Colors.white
                                                : primaryColor,
                                            size: 25,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // Category Name
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  categoryName,
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
