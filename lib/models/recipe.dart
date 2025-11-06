class Recipe {
  String recipeID;
  String userID;
  final String name;
  final double rating;
  final String prepTime;
  final String cookingTime;
  final String totalTime;
  final String category;
  final String tag;
  final List<String> ingredients;
  final List<String> directions;
  bool isFavorite;
  String? imageUrl;

  Recipe({
    this.recipeID = '',
    required this.userID,
    required this.name,
    required this.rating,
    required this.prepTime,
    required this.cookingTime,
    required this.totalTime,
    required this.category,
    required this.tag,
    required this.ingredients,
    required this.directions,
    required this.isFavorite,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeID': recipeID,
      'userID': userID,
      'name': name,
      'rating': rating,
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'totalTime': totalTime,
      'category': category,
      'tag': tag,
      'ingredients': ingredients,
      'directions': directions,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
    };
  }

  static Recipe fromJson(Map<String, dynamic> json) => Recipe(
    recipeID: json['recipeID'] ?? '',
    userID: json['userID'] ?? '',
    name: json['name'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    prepTime: json['prepTime'] ?? '',
    cookingTime: json['cookingTime'] ?? '',
    totalTime: json['totalTime'] ?? '',
    category: json['category'] ?? '',
    tag: json['tag'] ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    directions: List<String>.from(json['directions'] ?? []),
    isFavorite: json['isFavorite'] ?? false,
    imageUrl: json['imageUrl'],
  );
}
