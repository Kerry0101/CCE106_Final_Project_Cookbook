class Recipe {
  String recipeID;
  String userID;
  final String name;
  final double rating;
  final int reviewCount;
  final String prepTime;
  final String cookingTime;
  final String totalTime;
  final String category;
  final String tag;
  final List<String> ingredients;
  final List<String> directions;
  String? imageUrl;
  String status; // 'pending', 'approved', 'rejected'
  DateTime? submittedAt;
  DateTime? approvedAt;
  String? approvedBy;
  String? rejectionReason;

  Recipe({
    this.recipeID = '',
    required this.userID,
    required this.name,
    required this.rating,
    this.reviewCount = 0,
    required this.prepTime,
    required this.cookingTime,
    required this.totalTime,
    required this.category,
    required this.tag,
    required this.ingredients,
    required this.directions,
    this.imageUrl,
    this.status = 'pending',
    this.submittedAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipeID': recipeID,
      'userID': userID,
      'name': name,
      'rating': rating,
      'reviewCount': reviewCount,
      'prepTime': prepTime,
      'cookingTime': cookingTime,
      'totalTime': totalTime,
      'category': category,
      'tag': tag,
      'ingredients': ingredients,
      'directions': directions,
      'imageUrl': imageUrl,
      'status': status,
      'submittedAt': submittedAt,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
    };
  }

  static Recipe fromJson(Map<String, dynamic> json) => Recipe(
    recipeID: json['recipeID'] ?? '',
    userID: json['userID'] ?? '',
    name: json['name'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    reviewCount: json['reviewCount'] ?? 0,
    prepTime: json['prepTime'] ?? '',
    cookingTime: json['cookingTime'] ?? '',
    totalTime: json['totalTime'] ?? '',
    category: json['category'] ?? '',
    tag: json['tag'] ?? '',
    ingredients: List<String>.from(json['ingredients'] ?? []),
    directions: List<String>.from(json['directions'] ?? []),
    imageUrl: json['imageUrl'],
    status: json['status'] ?? 'pending',
    submittedAt: json['submittedAt'] != null 
        ? (json['submittedAt'] as dynamic).toDate() 
        : null,
    approvedAt: json['approvedAt'] != null 
        ? (json['approvedAt'] as dynamic).toDate() 
        : null,
    approvedBy: json['approvedBy'],
    rejectionReason: json['rejectionReason'],
  );
}
