import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cookbook/models/user_profile.dart';
import 'package:cookbook/services/cloudinary_service.dart';

class UserProfileService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  static String get currentUserId => _auth.currentUser!.uid;

  /// Create or update user profile in Firestore
  static Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
    String? phoneNumber,
    String role = 'user',
  }) async {
    try {
      final userProfile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        photoURL: photoURL,
        phoneNumber: phoneNumber,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .set(userProfile.toFirestore(), SetOptions(merge: true));

      debugPrint('User profile created/updated successfully');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by ID
  static Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        return null;
      }

      return UserProfile.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Get current user profile
  static Future<UserProfile?> getCurrentUserProfile() async {
    return getUserProfile(currentUserId);
  }

  /// Stream of current user profile
  static Stream<UserProfile?> getCurrentUserProfileStream() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc);
    });
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? bio,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (bio != null) updates['bio'] = bio;

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update(updates);

      // Also update Firebase Auth display name if changed
      if (displayName != null && _auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
      }

      debugPrint('User profile updated successfully');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update profile picture
  static Future<String> updateProfilePicture(
    dynamic imageFile, 
    String fileName,
    {bool isWeb = false}
  ) async {
    try {
      String? imageUrl;

      if (isWeb && imageFile is List<int>) {
        // Web: upload bytes
        imageUrl = await CloudinaryService.uploadImageBytes(
          imageFile,
          fileName,
        );
      } else {
        // Mobile: upload file
        imageUrl = await CloudinaryService.uploadImage(imageFile);
      }

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Update Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'photoURL': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePhotoURL(imageUrl);
      }

      debugPrint('Profile picture updated successfully');
      return imageUrl;
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      rethrow;
    }
  }

  /// Delete profile picture
  static Future<void> deleteProfilePicture() async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'photoURL': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update Firebase Auth
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updatePhotoURL(null);
      }

      debugPrint('Profile picture deleted successfully');
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
      rethrow;
    }
  }

  /// Update email
  static Future<void> updateEmail(String newEmail, String currentPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth (newer method)
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
      } catch (e) {
        // Fallback for older Firebase versions
        debugPrint('Using legacy updateEmail: $e');
        // Note: updateEmail is deprecated, using dynamic call
        await (user as dynamic).updateEmail(newEmail);
        await user.sendEmailVerification();
      }

      // Update email in Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Email updated successfully');
    } catch (e) {
      debugPrint('Error updating email: $e');
      rethrow;
    }
  }

  /// Change password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      debugPrint('Password changed successfully');
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  /// Admin: Get all users
  static Future<List<UserProfile>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      rethrow;
    }
  }

  /// Admin: Stream of all users
  static Stream<List<UserProfile>> getAllUsersStream() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromFirestore(doc))
            .toList());
  }

  /// Admin: Update user role
  static Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('User role updated successfully');
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  /// Admin: Delete user profile picture
  static Future<void> deleteUserProfilePicture(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'photoURL': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('User profile picture deleted by admin');
    } catch (e) {
      debugPrint('Error deleting user profile picture: $e');
      rethrow;
    }
  }

  /// Admin: Update any user's profile picture
  static Future<String> updateUserProfilePicture({
    required String uid,
    required dynamic imageFile,
    required String fileName,
    bool isWeb = false,
  }) async {
    try {
      String? imageUrl;

      if (isWeb && imageFile is List<int>) {
        imageUrl = await CloudinaryService.uploadImageBytes(
          imageFile,
          fileName,
        );
      } else {
        imageUrl = await CloudinaryService.uploadImage(imageFile);
      }

      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'photoURL': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('User profile picture updated by admin');
      return imageUrl;
    } catch (e) {
      debugPrint('Error updating user profile picture: $e');
      rethrow;
    }
  }

  /// Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.isAdmin ?? false;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }
}
