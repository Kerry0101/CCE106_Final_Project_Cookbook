import 'package:email_validator/email_validator.dart';

/// User-friendly validation utilities for form fields
class Validators {
  /// Validates that a field is not empty
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates email address with user-friendly messages
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address';
    }
    
    final trimmedValue = value.trim();
    
    if (!EmailValidator.validate(trimmedValue)) {
      // Check for common mistakes
      if (!trimmedValue.contains('@')) {
        return 'Email must include @ symbol (e.g., name@example.com)';
      }
      if (!trimmedValue.contains('.')) {
        return 'Email must include a domain (e.g., name@example.com)';
      }
      if (trimmedValue.startsWith('@')) {
        return 'Email cannot start with @ symbol';
      }
      if (trimmedValue.endsWith('@')) {
        return 'Email cannot end with @ symbol';
      }
      return 'Please enter a valid email address (e.g., name@example.com)';
    }
    return null;
  }

  /// Validates password with user-friendly messages
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters long';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match. Please try again';
    }
    
    return null;
  }

  /// Validates name with user-friendly messages
  static String? name(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return '$fieldName must be at least 2 characters long';
    }
    
    if (trimmedValue.length > 50) {
      return '$fieldName cannot exceed 50 characters';
    }
    
    // Check for invalid characters (only letters, spaces, hyphens, and apostrophes)
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(trimmedValue)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validates phone number with user-friendly messages
  static String? phone(String? value, {bool isRequired = false}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) {
        return 'Please enter your phone number';
      }
      return null; // Optional field
    }
    
    final trimmedValue = value.trim();
    
    if (!trimmedValue.startsWith('+')) {
      return 'Phone number must start with country code (e.g., +1 for USA, +44 for UK)';
    }
    
    if (trimmedValue.length < 10) {
      return 'Phone number is too short. Please include country code and number';
    }
    
    if (trimmedValue.length > 15) {
      return 'Phone number is too long. Please check and try again';
    }
    
    // Check if it contains only digits and + at the start
    if (!RegExp(r'^\+[0-9]+$').hasMatch(trimmedValue)) {
      return 'Phone number can only contain numbers and must start with +';
    }
    
    return null;
  }

  /// Validates age with user-friendly messages
  static String? age(String? value, {bool isRequired = false, int minAge = 13, int maxAge = 120}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) {
        return 'Please enter your age';
      }
      return null; // Optional field
    }
    
    final ageValue = int.tryParse(value.trim());
    
    if (ageValue == null) {
      return 'Age must be a valid number';
    }
    
    if (ageValue < minAge) {
      return 'You must be at least $minAge years old to use this app';
    }
    
    if (ageValue > maxAge) {
      return 'Please enter a valid age (maximum $maxAge years)';
    }
    
    return null;
  }

  /// Validates date of birth
  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Please select your date of birth';
    }
    
    final today = DateTime.now();
    final age = today.year - value.year;
    final isBeforeBirthday = today.month < value.month || 
                            (today.month == value.month && today.day < value.day);
    final actualAge = isBeforeBirthday ? age - 1 : age;
    
    if (actualAge < 13) {
      return 'You must be at least 13 years old to use this app';
    }
    
    if (actualAge > 120) {
      return 'Please enter a valid date of birth';
    }
    
    if (value.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }
    
    return null;
  }

  /// Validates that a number is positive
  static String? positiveNumber(String? value, {String fieldName = 'This field', bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) {
        return 'Please enter $fieldName';
      }
      return null;
    }
    
    final number = int.tryParse(value.trim());
    
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    if (number > 10000) {
      return '$fieldName seems too large. Please check and try again';
    }
    
    return null;
  }

  /// Validates recipe name
  static String? recipeName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a recipe name';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return 'Recipe name must be at least 2 characters long';
    }
    
    if (trimmedValue.length > 100) {
      return 'Recipe name cannot exceed 100 characters';
    }
    
    return null;
  }

  /// Validates that a list is not empty
  static String? listNotEmpty(List<String>? list, {String fieldName = 'This list'}) {
    if (list == null || list.isEmpty) {
      return 'Please add at least one item to $fieldName';
    }
    
    if (list.every((item) => item.trim().isEmpty)) {
      return 'Please add at least one item to $fieldName';
    }
    
    return null;
  }

  /// Validates that a dropdown/selection is made
  static String? requiredSelection(dynamic value, {String fieldName = 'This field'}) {
    if (value == null || (value is String && value.isEmpty)) {
      return 'Please select $fieldName';
    }
    return null;
  }

  /// Validates verification code
  static String? verificationCode(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the verification code';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length != length) {
      return 'Verification code must be $length digits';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(trimmedValue)) {
      return 'Verification code can only contain numbers';
    }
    
    return null;
  }

  /// Validates that terms are accepted
  static String? termsAccepted(bool? value) {
    if (value == null || !value) {
      return 'Please accept the Terms and Privacy Policy to continue';
    }
    return null;
  }
}

