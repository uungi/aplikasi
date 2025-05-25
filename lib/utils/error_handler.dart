import 'package:flutter/material.dart';
import '../services/api_key_service.dart';
import '../services/ai_service.dart';
import 'app_logger.dart';

class ErrorHandler {
  // Handle different types of errors and provide user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is ApiKeyException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is SecurityException) {
      return 'Security issue detected. Please check your input.';
    } else if (error is AIServiceException) {
      return error.message;
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data format received.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Show error dialog
  static void showErrorDialog(BuildContext context, String title, dynamic error) {
    final message = getErrorMessage(error);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Handle API key related errors
  static Future<bool> handleApiKeyError(BuildContext context, dynamic error) async {
    if (error is ApiKeyException) {
      final shouldNavigate = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Required'),
          content: Text(error.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Setup API Key'),
            ),
          ],
        ),
      );

      if (shouldNavigate == true) {
        // Navigate to API key setup screen
        // You'll need to import the screen and navigate
        return true;
      }
    }
    return false;
  }

  // Log error for debugging
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error('Error in $context', error, stackTrace);
  }

  // Handle network errors with retry option
  static Future<bool> handleNetworkError(BuildContext context, dynamic error) async {
    if (error.toString().contains('SocketException') || 
        error.toString().contains('TimeoutException')) {
      
      final shouldRetry = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content: const Text('Unable to connect to the server. Would you like to retry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );

      return shouldRetry ?? false;
    }
    return false;
  }

  // Handle validation errors
  static void handleValidationError(BuildContext context, ValidationException error) {
    showErrorSnackBar(context, error);
  }

  // Handle security errors
  static void handleSecurityError(BuildContext context, SecurityException error) {
    AppLogger.security('Security exception occurred', {'error': error.message});
    showErrorDialog(context, 'Security Alert', error);
  }
}
