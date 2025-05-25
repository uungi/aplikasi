import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for storage
  static const String _apiKeyKey = 'openai_api_key';
  static const String _userPreferencesKey = 'user_preferences';

  // API Key operations
  static Future<void> storeApiKey(String apiKey) async {
    try {
      await _storage.write(key: _apiKeyKey, value: apiKey);
    } catch (e) {
      debugPrint('Error storing API key: $e');
      throw SecureStorageException('Failed to store API key securely');
    }
  }

  static Future<String?> getApiKey() async {
    try {
      return await _storage.read(key: _apiKeyKey);
    } catch (e) {
      debugPrint('Error reading API key: $e');
      return null;
    }
  }

  static Future<void> deleteApiKey() async {
    try {
      await _storage.delete(key: _apiKeyKey);
    } catch (e) {
      debugPrint('Error deleting API key: $e');
      throw SecureStorageException('Failed to delete API key');
    }
  }

  // User preferences operations
  static Future<void> storeUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final preferencesJson = preferences.toString();
      await _storage.write(key: _userPreferencesKey, value: preferencesJson);
    } catch (e) {
      debugPrint('Error storing user preferences: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserPreferences() async {
    try {
      final preferencesJson = await _storage.read(key: _userPreferencesKey);
      if (preferencesJson != null) {
        // Parse the preferences (you might want to use json.decode for complex data)
        return {}; // Placeholder - implement based on your needs
      }
      return null;
    } catch (e) {
      debugPrint('Error reading user preferences: $e');
      return null;
    }
  }

  // Clear all secure storage
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing secure storage: $e');
    }
  }

  // Check if storage is available
  static Future<bool> isStorageAvailable() async {
    try {
      await _storage.containsKey(key: 'test');
      return true;
    } catch (e) {
      debugPrint('Secure storage not available: $e');
      return false;
    }
  }
}

class SecureStorageException implements Exception {
  final String message;
  
  SecureStorageException(this.message);
  
  @override
  String toString() => 'SecureStorageException: $message';
}
