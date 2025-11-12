# Firestore Data Structure - Culinary Chronicles

This document provides a comprehensive overview of the Firestore database structure for the Culinary Chronicles cookbook application.

## Collections Overview

```
cookbook-firestore/
├── users/
├── recipes/
├── category_suggestions/
└── (future collections as needed)
```

---

## 1. Users Collection

**Path:** `users/{userId}`

Each document represents a user account in the system.

### Document Structure:
```javascript
{
  "uid": "string",              // Firebase Auth UID (matches document ID)
  "name": "string",             // User's display name
  "email": "string",            // User's email address
  "phone": "string",            // User's phone number (optional, for password recovery)
  "role": "string",             // "user" | "admin"
  "createdAt": Timestamp,       // Account creation timestamp
  "lastLogin": Timestamp        // Last login timestamp (optional)
}
```

### Subcollection: favorites
**Path:** `users/{userId}/favorites/{recipeId}`

Stores user-specific favorite recipes.

```javascript
{
  "recipeId": "string",         // ID of the favorited recipe (matches document ID)
  "addedAt": Timestamp          // When recipe was favorited
}
```

**Note:** The document ID is the recipe ID, making it easy to check if a recipe is favorited and preventing duplicates.

### Example:
```javascript
// User document
users/abc123 = {
  "uid": "abc123",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "role": "user",
  "createdAt": Timestamp(2025-01-15),
  "lastLogin": Timestamp(2025-11-12)
}

// Favorite recipe
users/abc123/favorites/recipe456 = {
  "recipeId": "recipe456",
  "addedAt": Timestamp(2025-11-10)
}
```

---

## 2. Recipes Collection

**Path:** `recipes/{recipeId}`

Each document represents a recipe submitted by a user.

### Document Structure:
```javascript
{
  "recipeID": "string",         // Unique recipe ID (matches document ID)
  "userID": "string",           // ID of user who created the recipe
  "name": "string",             // Recipe name/title
  "rating": number,             // Recipe rating (0.0 - 5.0)
  "prepTime": "string",         // Preparation time (e.g., "15 min")
  "cookingTime": "string",      // Cooking time (e.g., "30 min")
  "totalTime": "string",        // Total time (e.g., "45 min")
  "category": "string",         // Recipe category (see Categories section below)
  "tag": "string",              // Additional tag/classification
  "ingredients": [string],      // Array of ingredient strings
  "directions": [string],       // Array of step-by-step instructions
  "imageUrl": "string",         // URL to recipe image (Cloudinary)
  
  // Moderation fields
  "status": "string",           // "pending" | "approved" | "rejected"
  "submittedAt": Timestamp,     // When recipe was submitted
  "approvedAt": Timestamp,      // When recipe was approved (nullable)
  "approvedBy": "string",       // Admin user ID who approved (nullable)
  "rejectionReason": "string"   // Reason for rejection (nullable)
}
```

### Recipe Categories:
Current predefined categories:
- All (filter option, not stored)
- Appetizer
- Breakfast
- Lunch
- Dinner
- Dessert
- Snack
- Beverage
- Soup
- Salad
- Main Course

### Recipe Statuses:
- **pending**: Newly submitted, awaiting admin review
- **approved**: Approved by admin, visible to all users
- **rejected**: Rejected by admin, only visible to recipe creator

### Example:
```javascript
recipes/recipe123 = {
  "recipeID": "recipe123",
  "userID": "abc123",
  "name": "Chocolate Chip Cookies",
  "rating": 4.5,
  "prepTime": "15 min",
  "cookingTime": "12 min",
  "totalTime": "27 min",
  "category": "Dessert",
  "tag": "Baked Goods",
  "ingredients": [
    "2 cups all-purpose flour",
    "1 cup butter, softened",
    "3/4 cup sugar",
    "2 eggs",
    "1 tsp vanilla extract",
    "1 tsp baking soda",
    "2 cups chocolate chips"
  ],
  "directions": [
    "Preheat oven to 375°F (190°C)",
    "Mix butter and sugar until fluffy",
    "Beat in eggs and vanilla",
    "Combine flour and baking soda, then add to butter mixture",
    "Stir in chocolate chips",
    "Drop spoonfuls onto baking sheet",
    "Bake 9-11 minutes until golden"
  ],
  "imageUrl": "https://res.cloudinary.com/...cookies.jpg",
  "status": "approved",
  "submittedAt": Timestamp(2025-11-01),
  "approvedAt": Timestamp(2025-11-02),
  "approvedBy": "admin789",
  "rejectionReason": null
}
```

---

## 3. Category Suggestions Collection

**Path:** `category_suggestions/{suggestionId}`

Stores user-submitted category suggestions for admin review.

### Document Structure:
```javascript
{
  "id": "string",               // Unique suggestion ID (matches document ID)
  "categoryName": "string",     // Suggested category name
  "description": "string",      // Description/explanation of the category
  "suggestedBy": "string",      // User ID who submitted the suggestion
  
  // Review status fields
  "status": "string",           // "pending" | "approved" | "rejected"
  "submittedAt": Timestamp,     // When suggestion was submitted
  "reviewedAt": Timestamp,      // When suggestion was reviewed (nullable)
  "reviewedBy": "string",       // Admin user ID who reviewed (nullable)
  "rejectionReason": "string"   // Reason for rejection (nullable)
}
```

### Category Suggestion Statuses:
- **pending**: Newly submitted, awaiting admin review
- **approved**: Approved by admin (category can be added to system)
- **rejected**: Rejected by admin with reason provided

### Example:
```javascript
category_suggestions/cat001 = {
  "id": "cat001",
  "categoryName": "Vegan",
  "description": "Recipes that contain no animal products - perfect for plant-based diets",
  "suggestedBy": "abc123",
  "status": "pending",
  "submittedAt": Timestamp(2025-11-12),
  "reviewedAt": null,
  "reviewedBy": null,
  "rejectionReason": null
}

category_suggestions/cat002 = {
  "id": "cat002",
  "categoryName": "Gluten-Free",
  "description": "Recipes suitable for people with gluten intolerance or celiac disease",
  "suggestedBy": "def456",
  "status": "approved",
  "submittedAt": Timestamp(2025-11-10),
  "reviewedAt": Timestamp(2025-11-11),
  "reviewedBy": "admin789",
  "rejectionReason": null
}

category_suggestions/cat003 = {
  "id": "cat003",
  "categoryName": "Fast Food",
  "description": "Quick fast food recipes",
  "suggestedBy": "ghi789",
  "status": "rejected",
  "submittedAt": Timestamp(2025-11-08),
  "reviewedAt": Timestamp(2025-11-09),
  "reviewedBy": "admin789",
  "rejectionReason": "Category too broad and conflicts with existing 'Snack' category. Consider suggesting more specific categories like 'Burgers' or 'Quick Meals'."
}
```

---

## Firestore Security Rules (Recommended)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Users can read their own document, admins can read all
      allow read: if isOwner(userId) || isAdmin();
      
      // Users can create their own document during signup
      allow create: if isSignedIn() && request.auth.uid == userId;
      
      // Users can update their own document (except role)
      allow update: if isOwner(userId) && 
                       request.resource.data.role == resource.data.role;
      
      // Only admins can delete users
      allow delete: if isAdmin();
      
      // Favorites subcollection
      match /favorites/{recipeId} {
        // Users can manage their own favorites
        allow read, write: if isOwner(userId);
      }
    }
    
    // Recipes collection
    match /recipes/{recipeId} {
      // Anyone can read approved recipes
      // Users can read their own recipes (any status)
      // Admins can read all recipes
      allow read: if resource.data.status == 'approved' || 
                     isOwner(resource.data.userID) || 
                     isAdmin();
      
      // Authenticated users can create recipes
      allow create: if isSignedIn() && 
                       request.resource.data.userID == request.auth.uid &&
                       request.resource.data.status == 'pending';
      
      // Users can update their own pending recipes
      // Admins can update any recipe (for moderation)
      allow update: if (isOwner(resource.data.userID) && 
                        resource.data.status == 'pending') || 
                       isAdmin();
      
      // Users can delete their own recipes
      // Admins can delete any recipe
      allow delete: if isOwner(resource.data.userID) || isAdmin();
    }
    
    // Category suggestions collection
    match /category_suggestions/{suggestionId} {
      // Users can read their own suggestions
      // Admins can read all suggestions
      allow read: if isOwner(resource.data.suggestedBy) || isAdmin();
      
      // Authenticated users can create suggestions
      allow create: if isSignedIn() && 
                       request.resource.data.suggestedBy == request.auth.uid &&
                       request.resource.data.status == 'pending';
      
      // Only admins can update (approve/reject) suggestions
      allow update: if isAdmin();
      
      // Only admins can delete suggestions
      allow delete: if isAdmin();
    }
  }
}
```

---

## Queries Used in the App

### User Queries:
```dart
// Get user details
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .snapshots()

// Check if user is admin
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .get()
  .then((doc) => doc.data()?['role'] == 'admin')
```

### Recipe Queries:
```dart
// Get all approved recipes
FirebaseFirestore.instance
  .collection('recipes')
  .where('status', isEqualTo: 'approved')
  .snapshots()

// Get approved recipes by category
FirebaseFirestore.instance
  .collection('recipes')
  .where('status', isEqualTo: 'approved')
  .where('category', isEqualTo: 'Dessert')
  .snapshots()

// Get user's own recipes (all statuses)
FirebaseFirestore.instance
  .collection('recipes')
  .where('userID', isEqualTo: userId)
  .snapshots()

// Get pending recipes (admin view)
FirebaseFirestore.instance
  .collection('recipes')
  .where('status', isEqualTo: 'pending')
  .orderBy('submittedAt', descending: true)
  .snapshots()

// Count user's recipes
FirebaseFirestore.instance
  .collection('recipes')
  .where('userID', isEqualTo: userId)
  .get()
  .then((snapshot) => snapshot.docs.length)
```

### Favorites Queries:
```dart
// Check if recipe is favorited by user
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('favorites')
  .doc(recipeId)
  .snapshots()
  .map((doc) => doc.exists)

// Get user's favorite recipes
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('favorites')
  .snapshots()
  .asyncMap((favSnapshot) async {
    final favoriteIds = favSnapshot.docs.map((doc) => doc.id).toList();
    return await FirebaseFirestore.instance
      .collection('recipes')
      .where(FieldPath.documentId, whereIn: favoriteIds)
      .get();
  })

// Add recipe to favorites
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('favorites')
  .doc(recipeId)
  .set({
    'recipeId': recipeId,
    'addedAt': FieldValue.serverTimestamp(),
  })

// Remove recipe from favorites
FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .collection('favorites')
  .doc(recipeId)
  .delete()
```

### Category Suggestions Queries:
```dart
// Get all category suggestions with status filter
FirebaseFirestore.instance
  .collection('category_suggestions')
  .where('status', isEqualTo: 'pending')
  .orderBy('submittedAt', descending: true)
  .snapshots()

// Count pending category suggestions
FirebaseFirestore.instance
  .collection('category_suggestions')
  .where('status', isEqualTo: 'pending')
  .get()
  .then((snapshot) => snapshot.docs.length)

// Submit category suggestion
FirebaseFirestore.instance
  .collection('category_suggestions')
  .doc()
  .set({
    'id': docId,
    'categoryName': name,
    'description': description,
    'suggestedBy': userId,
    'status': 'pending',
    'submittedAt': FieldValue.serverTimestamp(),
    'reviewedAt': null,
    'reviewedBy': null,
    'rejectionReason': null,
  })

// Approve category suggestion
FirebaseFirestore.instance
  .collection('category_suggestions')
  .doc(suggestionId)
  .update({
    'status': 'approved',
    'reviewedAt': FieldValue.serverTimestamp(),
    'reviewedBy': adminUserId,
  })

// Reject category suggestion
FirebaseFirestore.instance
  .collection('category_suggestions')
  .doc(suggestionId)
  .update({
    'status': 'rejected',
    'reviewedAt': FieldValue.serverTimestamp(),
    'reviewedBy': adminUserId,
    'rejectionReason': reason,
  })
```

---

## Indexes Required

To optimize queries, create these Firestore indexes:

### Recipes Collection:
```
Collection: recipes
Fields: status (Ascending), submittedAt (Descending)
Query Scope: Collection

Collection: recipes
Fields: status (Ascending), category (Ascending)
Query Scope: Collection

Collection: recipes
Fields: userID (Ascending), submittedAt (Descending)
Query Scope: Collection
```

### Category Suggestions Collection:
```
Collection: category_suggestions
Fields: status (Ascending), submittedAt (Descending)
Query Scope: Collection

Collection: category_suggestions
Fields: suggestedBy (Ascending), status (Ascending)
Query Scope: Collection
```

**Note:** Firestore will automatically prompt you to create these indexes when you first run queries that require them. Click the provided link to auto-generate the index.

---

## Best Practices

### 1. Data Validation
- Always validate data on the client before writing to Firestore
- Use Firestore Security Rules for server-side validation
- Ensure required fields are never null/empty

### 2. Timestamps
- Use `FieldValue.serverTimestamp()` for consistency
- Store all timestamps as Firestore Timestamp objects
- Convert to DateTime in Dart when needed: `timestamp.toDate()`

### 3. User Privacy
- Store minimal personal information
- Use Firebase Authentication for sensitive data (passwords)
- Implement proper security rules to protect user data

### 4. Favorites Implementation
- Use subcollection instead of array to avoid document size limits
- Document ID = Recipe ID for easy lookup and prevention of duplicates
- Delete favorite documents instead of marking as deleted

### 5. Moderation Workflow
- All new content starts as 'pending'
- Store reviewer information for audit trails
- Provide clear rejection reasons for user feedback

### 6. Query Optimization
- Create composite indexes for complex queries
- Use `.limit()` for large result sets
- Consider pagination for better performance
- Cache frequently accessed data locally

### 7. Scalability Considerations
- Current structure supports thousands of recipes/users
- For larger scale, consider:
  - Algolia for full-text search
  - Cloud Functions for complex aggregations
  - Firebase Storage Rules for image access control
  - Pagination for recipe lists

---

## Migration Notes

If you need to migrate existing data or add new fields:

### Adding Phone Field to Existing Users:
```dart
// One-time migration script
final users = await FirebaseFirestore.instance.collection('users').get();
for (var doc in users.docs) {
  if (!doc.data().containsKey('phone')) {
    await doc.reference.update({'phone': ''});
  }
}
```

### Converting Old Favorites System:
```dart
// Migrate from recipe.isFavorite to user favorites subcollection
// Run this once if you had old favorite system
final recipes = await FirebaseFirestore.instance
  .collection('recipes')
  .where('isFavorite', isEqualTo: true)
  .get();

for (var recipe in recipes.docs) {
  final recipeId = recipe.id;
  final userId = recipe.data()['userID'];
  
  // Create favorite document in new structure
  await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .collection('favorites')
    .doc(recipeId)
    .set({
      'recipeId': recipeId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  
  // Remove old field from recipe
  await recipe.reference.update({'isFavorite': FieldValue.delete()});
}
```

---

## Troubleshooting

### Common Issues:

1. **"Missing or insufficient permissions"**
   - Check Firestore Security Rules
   - Ensure user is authenticated
   - Verify user has correct role for admin features

2. **"Index required" error**
   - Click the link in the error message
   - Or manually create index in Firebase Console
   - Wait a few minutes for index to build

3. **Favorites not showing across accounts**
   - Verify using subcollection structure (not global boolean)
   - Check that userID is correctly set in queries
   - Ensure using `userID` getter function, not cached variable

4. **Category suggestions not appearing**
   - Verify document was created in correct collection
   - Check security rules allow read access
   - Ensure status filter matches expected value

---

## Future Enhancements

Potential additions to the data structure:

1. **Comments/Reviews Collection**
   ```javascript
   recipes/{recipeId}/reviews/{reviewId} = {
     userId, userName, rating, comment, createdAt
   }
   ```

2. **User Following System**
   ```javascript
   users/{userId}/following/{followedUserId} = { followedAt }
   users/{userId}/followers/{followerUserId} = { followedAt }
   ```

3. **Meal Plans Collection**
   ```javascript
   users/{userId}/meal_plans/{planId} = {
     name, date, recipes: [recipeIds], createdAt
   }
   ```

4. **Shopping Lists Enhancement**
   ```javascript
   users/{userId}/shopping_lists/{listId}/items/{itemId} = {
     name, quantity, checked, recipeId
   }
   ```

5. **Recipe Analytics**
   ```javascript
   recipes/{recipeId}/analytics = {
     views, favorites, shares, avgRating
   }
   ```

---

**Last Updated:** November 12, 2025  
**App Version:** 1.0.0  
**Firestore Version:** Latest
