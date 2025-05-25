import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'performance_monitor.dart';

class AppCache {
  static SharedPreferences? _prefs;
  static Directory? _cacheDir;
  static final Map<String, dynamic> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50;
  static const Duration _defaultCacheExpiry = Duration(hours: 24);
  
  // Initialize cache
  static Future<void> initialize() async {
    PerformanceMonitor.startOperation('cache_initialization');
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _cacheDir = await getTemporaryDirectory();
      
      // Clean expired cache on startup
      await _cleanExpiredCache();
      
      debugPrint('✅ Cache initialized successfully');
    } catch (e) {
      debugPrint('❌ Cache initialization failed: $e');
    } finally {
      PerformanceMonitor.endOperation('cache_initialization');
    }
  }
  
  // Store data in memory cache
  static void setMemoryCache(String key, dynamic value) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      // Remove oldest entry
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
    
    _memoryCache[key] = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  // Get data from memory cache
  static T? getMemoryCache<T>(String key, {Duration? maxAge}) {
    final cached = _memoryCache[key];
    if (cached == null) return null;
    
    final timestamp = cached['timestamp'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    final maxAgeMs = (maxAge ?? _defaultCacheExpiry).inMilliseconds;
    
    if (age > maxAgeMs) {
      _memoryCache.remove(key);
      return null;
    }
    
    return cached['value'] as T?;
  }
  
  // Store data in persistent cache
  static Future<void> setPersistentCache(String key, dynamic value, {Duration? expiry}) async {
    if (_prefs == null) await initialize();
    
    final cacheData = {
      'value': value,
      'expiry': DateTime.now().add(expiry ?? _defaultCacheExpiry).millisecondsSinceEpoch,
    };
    
    try {
      await _prefs!.setString(key, json.encode(cacheData));
    } catch (e) {
      debugPrint('Error storing persistent cache: $e');
    }
  }
  
  // Get data from persistent cache
  static Future<T?> getPersistentCache<T>(String key) async {
    if (_prefs == null) await initialize();
    
    try {
      final cachedString = _prefs!.getString(key);
      if (cachedString == null) return null;
      
      final cacheData = json.decode(cachedString);
      final expiry = cacheData['expiry'] as int;
      
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        // Cache expired, remove it
        await _prefs!.remove(key);
        return null;
      }
      
      return cacheData['value'] as T?;
    } catch (e) {
      debugPrint('Error reading persistent cache: $e');
      return null;
    }
  }
  
  // Store file in cache directory
  static Future<File?> cacheFile(String key, List<int> data) async {
    if (_cacheDir == null) await initialize();
    
    try {
      final file = File('${_cacheDir!.path}/$key');
      await file.writeAsBytes(data);
      
      // Store metadata
      await setPersistentCache('${key}_metadata', {
        'size': data.length,
        'created': DateTime.now().millisecondsSinceEpoch,
      });
      
      return file;
    } catch (e) {
      debugPrint('Error caching file: $e');
      return null;
    }
  }
  
  // Get cached file
  static Future<File?> getCachedFile(String key) async {
    if (_cacheDir == null) await initialize();
    
    try {
      final file = File('${_cacheDir!.path}/$key');
      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      debugPrint('Error reading cached file: $e');
    }
    
    return null;
  }
  
  // Clear all caches
  static Future<void> clearAll() async {
    PerformanceMonitor.startOperation('cache_clear_all');
    
    try {
      // Clear memory cache
      _memoryCache.clear();
      
      // Clear persistent cache
      if (_prefs != null) {
        await _prefs!.clear();
      }
      
      // Clear file cache
      if (_cacheDir != null && await _cacheDir!.exists()) {
        await _cacheDir!.delete(recursive: true);
        _cacheDir = await getTemporaryDirectory();
      }
      
      debugPrint('✅ All caches cleared');
    } catch (e) {
      debugPrint('❌ Error clearing caches: $e');
    } finally {
      PerformanceMonitor.endOperation('cache_clear_all');
    }
  }
  
  // Get cache size
  static Future<Map<String, int>> getCacheSize() async {
    int memorySize = 0;
    int persistentSize = 0;
    int fileSize = 0;
    
    try {
      // Memory cache size (approximate)
      memorySize = _memoryCache.length * 1024; // Rough estimate
      
      // Persistent cache size
      if (_prefs != null) {
        final keys = _prefs!.getKeys();
        for (final key in keys) {
          final value = _prefs!.getString(key);
          if (value != null) {
            persistentSize += value.length;
          }
        }
      }
      
      // File cache size
      if (_cacheDir != null && await _cacheDir!.exists()) {
        final files = await _cacheDir!.list().toList();
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            fileSize += stat.size;
          }
        }
      }
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
    }
    
    return {
      'memory_bytes': memorySize,
      'persistent_bytes': persistentSize,
      'file_bytes': fileSize,
      'total_bytes': memorySize + persistentSize + fileSize,
    };
  }
  
  // Clean expired cache entries
  static Future<void> _cleanExpiredCache() async {
    if (_prefs == null) return;
    
    try {
      final keys = _prefs!.getKeys().toList();
      final now = DateTime.now().millisecondsSinceEpoch;
      int cleanedCount = 0;
      
      for (final key in keys) {
        final cachedString = _prefs!.getString(key);
        if (cachedString != null) {
          try {
            final cacheData = json.decode(cachedString);
            final expiry = cacheData['expiry'] as int?;
            
            if (expiry != null && now > expiry) {
              await _prefs!.remove(key);
              cleanedCount++;
            }
          } catch (e) {
            // Invalid cache data, remove it
            await _prefs!.remove(key);
            cleanedCount++;
          }
        }
      }
      
      if (cleanedCount > 0) {
        debugPrint('🧹 Cleaned $cleanedCount expired cache entries');
      }
    } catch (e) {
      debugPrint('Error cleaning expired cache: $e');
    }
  }
  
  // Cache statistics
  static Map<String, dynamic> getStats() {
    return {
      'memory_cache_entries': _memoryCache.length,
      'memory_cache_max_size': _maxMemoryCacheSize,
      'persistent_cache_keys': _prefs?.getKeys().length ?? 0,
      'cache_dir_path': _cacheDir?.path,
    };
  }
}

// Cache key generator
class CacheKeys {
  static String userInput(String userId) => 'user_input_$userId';
  static String resumeTemplate(String templateId) => 'resume_template_$templateId';
  static String generatedResume(String inputHash) => 'generated_resume_$inputHash';
  static String generatedCoverLetter(String inputHash) => 'generated_cover_letter_$inputHash';
  static String apiResponse(String endpoint, String params) => 'api_${endpoint}_${params.hashCode}';
  static String userPreferences(String userId) => 'user_prefs_$userId';
  static String offlineTemplate(String templateId) => 'offline_template_$templateId';
}
