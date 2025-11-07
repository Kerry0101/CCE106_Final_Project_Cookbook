import 'dart:io';
import 'package:cookbook/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cookbook/models/categories.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/screens/recipes/recipe_about.dart';
import 'package:cookbook/services/firestore_functions.dart';
import 'package:cookbook/services/cloudinary_service.dart';
import 'package:cookbook/utils/colors.dart';
import 'package:cookbook/widgets/input_lists.dart';
import 'package:cookbook/widgets/textform_field.dart';

class recipeEdit extends StatefulWidget {
  final Recipe recipe;

  const recipeEdit({
    super.key,
    required this.recipe,
  });

  @override
  State<recipeEdit> createState() => _recipeEditState();
}

class _recipeEditState extends State<recipeEdit> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _recipeName = TextEditingController();
  final TextEditingController _recipePrepTime = TextEditingController();
  final TextEditingController _recipeCookingTime = TextEditingController();
  final TextEditingController _recipeTotalTime = TextEditingController();
  final TextEditingController _recipeTag = TextEditingController();

  List<String> _recipeIngredients = [];
  List<String> _recipeDirections = [];

  PlatformFile? pickedFile;
  String? _pickedImage;
  double _recipeRating = 0;
  String? _recipeSelectedCategory;
  late bool isFavorite;

  Utils utils = Utils();

  Future<String?> uploadFile() async {
    if (pickedFile == null) {
      return _pickedImage;
    }
    
    if (kIsWeb) {
      // For web, use bytes directly
      if (pickedFile!.bytes != null) {
        final imageUrl = await CloudinaryService.uploadImageBytes(
          pickedFile!.bytes!,
          pickedFile!.name,
        );
        return imageUrl;
      }
      return _pickedImage;
    } else {
      // For mobile, use File
      final file = File(pickedFile!.path!);
      final imageUrl = await CloudinaryService.uploadImage(file);
      return imageUrl;
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb, // For web, we need the bytes
    );
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  @override
  void initState() {
    super.initState();
    _recipeName.text = widget.recipe.name;
    _recipePrepTime.text = widget.recipe.prepTime;
    _recipeCookingTime.text = widget.recipe.cookingTime;
    _recipeTotalTime.text = widget.recipe.totalTime;
    _recipeSelectedCategory = widget.recipe.category;
    _recipeTag.text = widget.recipe.tag;
    _recipeRating = widget.recipe.rating;
    _recipeIngredients = widget.recipe.ingredients;
    _recipeDirections = widget.recipe.directions;
    isFavorite = widget.recipe.isFavorite;
    _pickedImage = widget.recipe.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                try {
                  String? imageUrl = await uploadFile();
                  if (pickedFile != null && imageUrl == null) {
                    utils.showSnackBar(
                        'Failed to upload image. Please try again.', Colors.red);
                    return;
                  }
                  
                  final recipe = Recipe(
                    recipeID: widget.recipe.recipeID,
                    userID: widget.recipe.userID,
                    name: _recipeName.text,
                    rating: _recipeRating,
                    prepTime: _recipePrepTime.text,
                    cookingTime: _recipeCookingTime.text,
                    totalTime: _recipeTotalTime.text,
                    category: _recipeSelectedCategory ?? '',
                    tag: _recipeTag.text,
                    ingredients: _recipeIngredients,
                    directions: _recipeDirections,
                    isFavorite: isFavorite,
                    imageUrl: imageUrl ?? widget.recipe.imageUrl,
                  );
                  await updateRecipe(recipe, recipe.recipeID);
                  Navigator.of(context).pop();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => RecipeAbout(recipe: recipe),
                    ),
                  );
                  utils.showSnackBar(
                      'Recipe updated successfully!', Colors.green);
                } catch (error) {
                  utils.showSnackBar(
                      'An error occurred. Please try again later.', Colors.red);
                }
              },
            ),
          ),
        ],
        title: Text(
          "Edit Recipe",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ListView(
        key: _formKey,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Recipe Image",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: selectFile,
                  child: pickedFile != null
                      ? Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.withOpacity(0.3),
                    child: kIsWeb
                        ? (pickedFile!.bytes != null
                            ? Image.memory(
                                pickedFile!.bytes!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : const Center(child: CircularProgressIndicator()))
                        : Image.file(
                            File(pickedFile!.path!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  )
                      : SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: ClipRRect(
                      child: _pickedImage != null
                          ? Image.network(
                        _pickedImage!,
                        fit: BoxFit.cover,
                      )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "Rating",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RatingBar.builder(
                  initialRating: _recipeRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 40,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (newRecipeRating) {
                    setState(() {
                      _recipeRating = newRecipeRating;
                    });
                  },
                ),
              ],
            ),
          ),
          TextBoxField(
            label: "Name",
            formController: _recipeName,
            placeholderText: "e.g. Beef Steak",
            onChanged: (_) {},
          ),
          TextBoxField(
            label: "Preparation Time (mins)",
            formController: _recipePrepTime,
            placeholderText: "In minutes",
            onChanged: (_) {
              _calculateTotalTime();
            },
          ),
          TextBoxField(
            label: "Cooking Time (mins)",
            formController: _recipeCookingTime,
            placeholderText: "In minutes",
            onChanged: (_) {
              _calculateTotalTime();
            },
          ),
          TextBoxField(
            label: "Total Time (mins)",
            formController: _recipeTotalTime,
            placeholderText: "In minutes",
            onChanged: (_) {},
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Category",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Form(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: DropdownButtonFormField<String>(
                          initialValue: _recipeSelectedCategory,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Select Course",
                          ),
                          items: categories.map((String category) {
                            //variable _courseList for the options
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _recipeSelectedCategory = newValue!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a course.';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextBoxField(
            label: "Tag",
            formController: _recipeTag,
            placeholderText: "Tag",
            onChanged: (_) {},
          ),
          InputLists(
              header: "Ingredients",
              listController: _recipeIngredients,
              label: "Ingredient "),
          InputLists(
            header: "Directions",
            listController: _recipeDirections,
            label: "Step ",
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    String? imageUrl = await uploadFile();
                    if (pickedFile != null && imageUrl == null) {
                      utils.showSnackBar(
                          'Failed to upload image. Please try again.', Colors.red);
                      return;
                    }
                    
                    final recipe = Recipe(
                      recipeID: widget.recipe.recipeID,
                      userID: widget.recipe.userID,
                      name: _recipeName.text,
                      rating: _recipeRating,
                      prepTime: _recipePrepTime.text,
                      cookingTime: _recipeCookingTime.text,
                      totalTime: _recipeTotalTime.text,
                      category: _recipeSelectedCategory ?? '',
                      tag: _recipeTag.text,
                      ingredients: _recipeIngredients,
                      directions: _recipeDirections,
                      isFavorite: isFavorite,
                      imageUrl: imageUrl ?? widget.recipe.imageUrl,
                    );
                    await updateRecipe(recipe, recipe.recipeID);
                    Navigator.of(context).pop();

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => RecipeAbout(recipe: recipe),
                      ),
                    );
                    utils.showSnackBar(
                        'Recipe updated successfully!', Colors.green);
          } catch (error) {
            debugPrint('Error: $error');
            utils.showSnackBar(
              'An error occurred. Please try again later.',
              Colors.red);
            }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.save, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Save',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _calculateTotalTime() {
    int cookingTime = int.tryParse(_recipeCookingTime.text) ?? 0;
    int prepTime = int.tryParse(_recipePrepTime.text) ?? 0;
    int totalTime = cookingTime + prepTime;
    _recipeTotalTime.text = '$totalTime mins';
  }
}
