import 'dart:io';

import 'package:cookbook/screens/home.dart';
import 'package:cookbook/utils/utils.dart';
import 'package:cookbook/utils/validators.dart';
import 'package:cookbook/utils/error_messages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_fonts/google_fonts.dart';

import 'package:cookbook/models/categories.dart';
import 'package:cookbook/models/recipe.dart';
import 'package:cookbook/services/firestore_functions.dart';
import 'package:cookbook/services/cloudinary_service.dart';
import 'package:cookbook/widgets/input_lists.dart';
import 'package:cookbook/widgets/textform_field.dart';
import 'package:cookbook/widgets/my_drawer.dart';
import 'package:cookbook/utils/colors.dart';

class recipeCreate extends StatefulWidget {
  const recipeCreate({super.key});

  @override
  State<recipeCreate> createState() => _recipeCreateState();
}

class _recipeCreateState extends State<recipeCreate> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final TextEditingController _recipeName = TextEditingController();
  final TextEditingController _recipePrepTime = TextEditingController();
  final TextEditingController _recipeCookingTime = TextEditingController();
  final TextEditingController _recipeTotalTime = TextEditingController();
  final TextEditingController _recipeTag = TextEditingController();
  final List<String> _recipeIngredients = [];
  final List<String> _recipeDirections = [];

  PlatformFile? pickedFile;
  String? _recipeSelectedCategory;

  Utils utils = Utils();

  Future<String?> uploadFile() async {
    if (pickedFile == null) return null;
    
    if (kIsWeb) {
      // For web, use bytes directly
      if (pickedFile!.bytes != null) {
        final imageUrl = await CloudinaryService.uploadImageBytes(
          pickedFile!.bytes!,
          pickedFile!.name,
        );
        return imageUrl;
      }
      return null;
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
    _recipeTotalTime.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(context, currentRoute: '/create-recipe'),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "New Recipe",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        iconTheme: IconThemeData(
          color: primaryColor,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [bgc1, bgc2, bgc3, bgc4],
          ),
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: ListView(
          children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Upload Recipe Image",
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
                      : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.withOpacity(0.3),
                    child: const Center(
                      child: Icon(
                        Icons.photo,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextBoxField(
            label: "Name",
            formController: _recipeName,
            placeholderText: "e.g. Beef Steak",
            onChanged: (_) {},
            validator: (value) => Validators.recipeName(value),
          ),
          TextBoxField(
            label: "Preparation Time (mins)",
            formController: _recipePrepTime,
            placeholderText: "In minutes (e.g., 15)",
            onChanged: (_) {
              _calculateTotalTime();
            },
            validator: (value) => Validators.positiveNumber(
              value,
              fieldName: 'preparation time',
            ),
          ),
          TextBoxField(
            label: "Cooking Time (mins)",
            formController: _recipeCookingTime,
            placeholderText: "In minutes (e.g., 30)",
            onChanged: (_) {
              _calculateTotalTime();
            },
            validator: (value) => Validators.positiveNumber(
              value,
              fieldName: 'cooking time',
            ),
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
                Text(
                  "Category",
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Form(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: StreamBuilder<List<String>>(
                          stream: readCategories(),
                          builder: (context, snapshot) {
                            final categoriesList = snapshot.data ?? defaultCategories;
                            
                            return DropdownButtonFormField<String>(
                              initialValue: _recipeSelectedCategory,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Select Category",
                              ),
                              menuMaxHeight: 300,
                              items: categoriesList.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: GoogleFonts.lato(),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _recipeSelectedCategory = newValue!;
                                });
                              },
                              validator: (value) => Validators.requiredSelection(
                                value,
                                fieldName: 'a category',
                              ),
                            );
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
            multiline: true,
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Enable autovalidation after first submit attempt
                  setState(() {
                    _autovalidateMode = AutovalidateMode.onUserInteraction;
                  });

                  // Validate all form fields
                  if (!_formKey.currentState!.validate()) {
                    utils.showError(
                      ErrorMessages.getValidationErrorMessage('all_fields'),
                    );
                    return;
                  }

                  // Additional validations for lists
                  final ingredientsError = Validators.listNotEmpty(
                    _recipeIngredients,
                    fieldName: 'ingredients',
                  );
                  if (ingredientsError != null) {
                    utils.showError(ingredientsError);
                    return;
                  }

                  final directionsError = Validators.listNotEmpty(
                    _recipeDirections,
                    fieldName: 'directions',
                  );
                  if (directionsError != null) {
                    utils.showError(directionsError);
                    return;
                  }

                  try {
                    // Remove empty ingredients and directions
                    _recipeIngredients.removeWhere((ingredient) => ingredient.trim().isEmpty);
                    _recipeDirections.removeWhere((direction) => direction.trim().isEmpty);

                    String? imageUrl;
                    if (pickedFile != null) {
                      try {
                        imageUrl = await uploadFile();
                        if (imageUrl == null) {
                          utils.showError(
                            'Failed to upload image. Please check your internet connection and try again.',
                          );
                          return;
                        }
                      } catch (e) {
                        utils.showError(
                          ErrorMessages.getGeneralErrorMessage(e),
                        );
                        return;
                      }
                    }

                    final recipe = Recipe(
                      recipeID: '',
                      userID: '',
                      name: _recipeName.text,
                      rating: 0.0, // Will be calculated from user reviews
                      prepTime: _recipePrepTime.text,
                      cookingTime: _recipeCookingTime.text,
                      totalTime: _recipeTotalTime.text,
                      category: _recipeSelectedCategory ?? '',
                      tag: _recipeTag.text,
                      ingredients: _recipeIngredients,
                      directions: _recipeDirections,
                      imageUrl: imageUrl,
                    );

                    // Create the recipe
                    await createRecipe(recipe);

                    if (!mounted) return;
                    
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                    utils.showSuccess(
                      ErrorMessages.getSuccessMessage('recipe_created'),
                    );
                  } catch (error) {
                    // Handle any errors that occur during the process
                    debugPrint('Error: $error');
                    if (mounted) {
                      utils.showError(
                        ErrorMessages.getGeneralErrorMessage(error),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Cookbook',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
        ),
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
