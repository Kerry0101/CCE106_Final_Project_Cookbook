import 'package:firebase_auth/firebase_auth.dart';

/// User-friendly error messages for the entire application
class ErrorMessages {
  /// Get user-friendly error message from Firebase Auth exceptions
  static String getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address. Please check your email or sign up for a new account.';
      
      case 'wrong-password':
        return 'Incorrect password. Please check your password and try again.';
      
      case 'email-already-in-use':
        return 'This email address is already registered. Please sign in or use a different email.';
      
      case 'invalid-email':
        return 'The email address you entered is not valid. Please check and try again.';
      
      case 'weak-password':
        return 'Your password is too weak. Please use at least 6 characters.';
      
      case 'user-disabled':
        return 'This account has been disabled. Please contact support for assistance.';
      
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes and try again.';
      
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      
      case 'requires-recent-login':
        return 'For security reasons, please sign out and sign in again to perform this action.';
      
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection and try again.';
      
      case 'invalid-verification-code':
        return 'The verification code you entered is incorrect. Please check and try again.';
      
      case 'invalid-verification-id':
        return 'Verification session expired. Please request a new code.';
      
      case 'session-expired':
        return 'Your session has expired. Please try again.';
      
      case 'credential-already-in-use':
        return 'This account is already linked to another user. Please use a different account.';
      
      case 'invalid-credential':
        return 'The credentials you provided are invalid. Please check and try again.';
      
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email but different sign-in method. Please use the correct sign-in method.';
      
      default:
        return e.message ?? 'An authentication error occurred. Please try again.';
    }
  }

  /// Get user-friendly error message for general exceptions
  static String getGeneralErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return getAuthErrorMessage(error);
    }
    
    final errorString = error.toString().toLowerCase();
    
    // Network errors
    if (errorString.contains('network') || 
        errorString.contains('connection') ||
        errorString.contains('socket') ||
        errorString.contains('timeout')) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    }
    
    // File/Image errors
    if (errorString.contains('file') || 
        errorString.contains('image') ||
        errorString.contains('upload')) {
      return 'There was a problem with the file. Please make sure the file is valid and try again.';
    }
    
    // Permission errors
    if (errorString.contains('permission') || 
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    }
    
    // Not found errors
    if (errorString.contains('not found') || 
        errorString.contains('404')) {
      return 'The requested item could not be found.';
    }
    
    // Server errors
    if (errorString.contains('server') || 
        errorString.contains('500') ||
        errorString.contains('503')) {
      return 'The server is temporarily unavailable. Please try again in a few moments.';
    }
    
    // Default message
    return 'Something went wrong. Please try again. If the problem persists, contact support.';
  }

  /// Get user-friendly success messages
  static String getSuccessMessage(String action) {
    switch (action.toLowerCase()) {
      case 'login':
        return 'Welcome back! You have successfully signed in.';
      case 'signup':
      case 'register':
        return 'Account created successfully! Please verify your email before signing in.';
      case 'logout':
        return 'You have been signed out successfully.';
      case 'recipe_created':
        return 'Recipe created successfully! It has been added to your cookbook.';
      case 'recipe_updated':
        return 'Recipe updated successfully! Your changes have been saved.';
      case 'recipe_deleted':
        return 'Recipe deleted successfully.';
      case 'profile_updated':
        return 'Profile updated successfully! Your changes have been saved.';
      case 'password_reset_sent':
        return 'Password reset link has been sent to your email. Please check your inbox.';
      case 'email_verified':
        return 'Email verified successfully! You can now sign in.';
      default:
        return 'Operation completed successfully!';
    }
  }

  /// Get user-friendly validation error messages
  static String getValidationErrorMessage(String field) {
    switch (field.toLowerCase()) {
      case 'email':
        return 'Please enter a valid email address';
      case 'password':
        return 'Password must be at least 6 characters long';
      case 'name':
        return 'Please enter your full name';
      case 'phone':
        return 'Please enter a valid phone number with country code';
      case 'age':
        return 'Please enter a valid age';
      case 'recipe_name':
        return 'Please enter a recipe name';
      case 'category':
        return 'Please select a category';
      case 'ingredients':
        return 'Please add at least one ingredient';
      case 'directions':
        return 'Please add at least one direction step';
      case 'all_fields':
        return 'Please fill in all required fields correctly';
      default:
        return 'Please fill in all required fields';
    }
  }

  /// Get user-friendly loading messages
  static String getLoadingMessage(String action) {
    switch (action.toLowerCase()) {
      case 'login':
        return 'Signing you in...';
      case 'signup':
        return 'Creating your account...';
      case 'upload':
        return 'Uploading your file...';
      case 'save':
        return 'Saving your changes...';
      case 'delete':
        return 'Deleting...';
      case 'load':
        return 'Loading...';
      default:
        return 'Please wait...';
    }
  }
}

