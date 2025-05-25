import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MemoryManager {
  static final Map<String, Timer> _timers = {};
  static final Map<String, StreamSubscription> _subscriptions = {};
  static final LRUCache<String, dynamic> _cache = LRUCache(maxSize: 100);
  
  // Register a timer for automatic cleanup
  static void registerTimer(String id, Timer timer) {
    // Cancel existing timer if any
    _timers[id]?.cancel();
    _timers[id] = timer;
  }
  
  // Register a stream subscription for automatic cleanup
  static void registerSubscription(String id, StreamSubscription subscription) {
    // Cancel existing subscription if any
    _subscriptions[id]?.cancel();
    _subscriptions[id] = subscription;
  }
  
  // Clean up specific resource
  static void cleanup(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    
    _subscriptions[id]?.cancel();
    _subscriptions.remove(id);
  }
  
  // Clean up all resources
  static void cleanupAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    _cache.clear();
    
    debugPrint('🧹 Memory cleanup completed');
  }
  
  // Cache management
  static void cacheData(String key, dynamic data) {
    _cache.put(key, data);
  }
  
  static T? getCachedData<T>(String key) {
    return _cache.get(key) as T?;
  }
  
  static void clearCache() {
    _cache.clear();
  }
  
  // Image memory optimization
  static ImageProvider optimizeImage(String imagePath, {int? width, int? height}) {
    return ResizeImage(
      AssetImage(imagePath),
      width: width,
      height: height,
      allowUpscaling: false,
    );
  }
  
  // Dispose controllers safely
  static void disposeController(dynamic controller) {
    try {
      if (controller is TextEditingController) {
        controller.dispose();
      } else if (controller is AnimationController) {
        controller.dispose();
      } else if (controller is ScrollController) {
        controller.dispose();
      } else if (controller is PageController) {
        controller.dispose();
      } else if (controller is TabController) {
        controller.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }
  
  // Memory pressure handling
  static void handleMemoryPressure() {
    debugPrint('🔴 Memory pressure detected, cleaning up...');
    
    // Clear caches
    clearCache();
    
    // Force garbage collection
    if (kDebugMode) {
      // Note: This is only for debugging, not recommended in production
      // System.gc() equivalent doesn't exist in Dart
    }
    
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    debugPrint('✅ Memory pressure cleanup completed');
  }
}

// LRU Cache implementation
class LRUCache<K, V> {
  final int maxSize;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  
  LRUCache({required this.maxSize});
  
  V? get(K key) {
    if (_cache.containsKey(key)) {
      // Move to end (most recently used)
      final value = _cache.remove(key)!;
      _cache[key] = value;
      return value;
    }
    return null;
  }
  
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }
  
  void clear() {
    _cache.clear();
  }
  
  int get length => _cache.length;
}

// Mixin for automatic memory management
mixin AutoMemoryManagement<T extends StatefulWidget> on State<T> {
  final List<String> _resourceIds = [];
  
  void registerResource(String id) {
    _resourceIds.add(id);
  }
  
  @override
  void dispose() {
    // Clean up all registered resources
    for (final id in _resourceIds) {
      MemoryManager.cleanup(id);
    }
    super.dispose();
  }
}
