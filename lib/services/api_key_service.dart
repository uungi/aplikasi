import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'secure_storage_service.dart';

class ApiKeyService {
  static String? _cachedApiKey;
  static bool _isInitialized = false;

  // Initialize the service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // First try to get from secure storage
      _cachedApiKey = await SecureStorageService.getApiKey();
      
      // If not found in secure storage, try environment variable
      if (_cachedApiKey == null || _cachedApiKey!.isEmpty) {
        final envApiKey = dotenv.env['OPENAI_API_KEY'];
        if (envApiKey != null && envApiKey.isNotEmpty) {
          _cachedApiKey = envApiKey;
          // Store it securely for future use
          await SecureStorageService.storeApiKey(envApiKey);
        }
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing API key service: $e');
      _isInitialized = true; // Mark as initialized even if failed
    }
  }

  // Get API key
  static Future<String> getApiKey() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_cachedApiKey == null || _cachedApiKey!.isEmpty) {
      throw ApiKeyException('API key not configured. Please set up your OpenAI API key.');
    }
    
    return _cachedApiKey!;
  }

  // Set API key (for user input)
  static Future<void> setApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      throw ApiKeyException('API key cannot be empty');
    }
    
    // Validate API key format
    if (!apiKey.startsWith('sk-')) {
      throw ApiKeyException('Invalid API key format');
    }
    
    try {
      await SecureStorageService.storeApiKey(apiKey);
      _cachedApiKey = apiKey;
    } catch (e) {
      throw ApiKeyException('Failed to store API key: $e');
    }
  }

  // Check if API key is available
  static Future<bool> hasApiKey() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    return _cachedApiKey != null && _cachedApiKey!.isNotEmpty;
  }

  // Clear API key
  static Future<void> clearApiKey() async {
    try {
      await SecureStorageService.deleteApiKey();
      _cachedApiKey = null;
    } catch (e) {
      debugPrint('Error clearing API key: $e');
    }
  }

  // Validate API key format
  static bool isValidApiKeyFormat(String apiKey) {
    return apiKey.startsWith('sk-') && apiKey.length >= 20;
  }

  // Get masked API key for display
  static String getMaskedApiKey(String apiKey) {
    if (apiKey.length <= 8) return '***';
    return '${apiKey.substring(0, 7)}...${apiKey.substring(apiKey.length - 4)}';
  }
}

class ApiKeyException implements Exception {
  final String message;
  
  ApiKeyException(this.message);
  
  @override
  String toString() => 'ApiKeyException: $message';
}
