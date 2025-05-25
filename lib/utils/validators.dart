import 'package:flutter/material.dart';

class Validators {
  // Basic validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    // Remove extra whitespace and check length
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (trimmedValue.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-'\.]+$");
    if (!nameRegex.hasMatch(trimmedValue)) {
      return 'Name contains invalid characters';
    }
    
    return null;
  }

  // Position validation
  static String? validatePosition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Position is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Position must be at least 2 characters';
    }
    
    if (trimmedValue.length > 100) {
      return 'Position must be less than 100 characters';
    }
    
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Text area validation (for experiences, education, etc.)
  static String? validateTextArea(String? value, String fieldName, {int maxLength = 1000}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Most text areas are optional
    }
    
    if (value.trim().length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }

  // Company name validation
  static String? validateCompany(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Company is optional
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length > 100) {
      return 'Company name must be less than 100 characters';
    }
    
    return null;
  }

  // API Key validation
  static String? validateApiKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'API Key is required';
    }
    
    final trimmedValue = value.trim();
    
    // OpenAI API keys typically start with 'sk-' and are 51 characters long
    if (!trimmedValue.startsWith('sk-')) {
      return 'Invalid API Key format';
    }
    
    if (trimmedValue.length < 20) {
      return 'API Key is too short';
    }
    
    return null;
  }

  // Contact information validation
  static String? validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact information is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 10) {
      return 'Please provide complete contact information';
    }
    
    if (trimmedValue.length > 500) {
      return 'Contact information is too long';
    }
    
    return null;
  }
}

class InputSanitizer {
  // Sanitize general text input
  static String sanitizeText(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>"\']'), '') // Remove potential HTML/script tags
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[^\w\s\-\.\,\!\?$$$$\[\]@#\$%\^&\*\+\=\_\|\\\/\:\;]'), ''); // Allow only safe characters
  }

  // Sanitize name input (more restrictive)
  static String sanitizeName(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z\s\-\'\.]'), '') // Only letters, spaces, hyphens, apostrophes, dots
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  // Sanitize email input
  static String sanitizeEmail(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9@\.\-_]'), ''); // Only valid email characters
  }

  // Sanitize phone input
  static String sanitizePhone(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[^0-9\+\-$$$$\s]'), ''); // Only numbers and phone formatting characters
  }

  // Check for potential security threats
  static bool containsSuspiciousContent(String input) {
    final suspiciousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      RegExp(r'eval\s*\(', caseSensitive: false),
      RegExp(r'expression\s*\(', caseSensitive: false),
      RegExp(r'vbscript:', caseSensitive: false),
      RegExp(r'data:text/html', caseSensitive: false),
    ];
    
    return suspiciousPatterns.any((pattern) => pattern.hasMatch(input));
  }

  // Validate input length
  static bool isValidLength(String input, {int minLength = 0, int maxLength = 1000}) {
    final length = input.trim().length;
    return length >= minLength && length <= maxLength;
  }
}
