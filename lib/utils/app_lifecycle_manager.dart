import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'memory_manager.dart';
import 'performance_monitor.dart';
import 'app_cache.dart';

class AppLifecycleManager extends WidgetsBindingObserver {
  static AppLifecycleManager? _instance;
  static AppLifecycleManager get instance {
    _instance ??= AppLifecycleManager._();
    return _instance!;
  }
  
  AppLifecycleManager._();
  
  bool _isInitialized = false;
  AppLifecycleState? _lastState;
  DateTime? _backgroundTime;
  
  // Initialize lifecycle management
  void initialize() {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
    
    debugPrint('🔄 App lifecycle manager initialized');
  }
  
  // Dispose lifecycle management
  void dispose() {
    if (!_isInitialized) return;
    
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    
    debugPrint('🔄 App lifecycle manager disposed');
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    debugPrint('🔄 App lifecycle changed: ${_lastState?.name} -> ${state.name}');
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
    }
    
    _lastState = state;
  }
  
  void _onAppResumed() {
    PerformanceMonitor.startOperation('app_resume');
    
    // Check if app was in background for a long time
    if (_backgroundTime != null) {
      final backgroundDuration = DateTime.now().difference(_backgroundTime!);
      
      if (backgroundDuration.inMinutes > 30) {
        // App was in background for more than 30 minutes
        debugPrint('🔄 App resumed after ${backgroundDuration.inMinutes} minutes');
        
        // Clear caches to free memory
        MemoryManager.clearCache();
        
        // Clear image cache
        PaintingBinding.instance.imageCache.clear();
        
        // Re-initialize critical services if needed
        _reinitializeCriticalServices();
      }
    }
    
    _backgroundTime = null;
    PerformanceMonitor.endOperation('app_resume');
  }
  
  void _onAppPaused() {
    PerformanceMonitor.startOperation('app_pause');
    
    _backgroundTime = DateTime.now();
    
    // Save critical data
    _saveCriticalData();
    
    // Clean up non-essential resources
    _cleanupNonEssentialResources();
    
    // Log performance summary
    PerformanceMonitor.logPerformanceSummary();
    
    PerformanceMonitor.endOperation('app_pause');
  }
  
  void _onAppDetached() {
    // App is being terminated
    debugPrint('🔄 App detached - performing final cleanup');
    
    // Final cleanup
    MemoryManager.cleanupAll();
    PerformanceMonitor.clearData();
  }
  
  void _onAppInactive() {
    // App is inactive (e.g., phone call, notification panel)
    debugPrint('🔄 App inactive');
  }
  
  void _onAppHidden() {
    // App is hidden (iOS specific)
    debugPrint('🔄 App hidden');
  }
  
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    
    debugPrint('🔴 Memory pressure detected by system');
    MemoryManager.handleMemoryPressure();
    
    // Additional memory cleanup
    _performEmergencyMemoryCleanup();
  }
  
  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    debugPrint('🌍 Locales changed: $locales');
  }
  
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    debugPrint('🌓 Platform brightness changed');
  }
  
  void _saveCriticalData() {
    // Save any critical data that needs to persist
    // This could include user input, draft data, etc.
    debugPrint('💾 Saving critical data');
  }
  
  void _cleanupNonEssentialResources() {
    // Clean up resources that can be recreated
    debugPrint('🧹 Cleaning up non-essential resources');
    
    // Clear some caches
    MemoryManager.clearCache();
    
    // Cancel non-critical timers
    // Note: Critical timers should be handled separately
  }
  
  void _reinitializeCriticalServices() {
    // Reinitialize services that might have been affected by long background time
    debugPrint('🔄 Reinitializing critical services');
    
    // Example: Refresh API tokens, reconnect to services, etc.
  }
  
  void _performEmergencyMemoryCleanup() {
    debugPrint('🚨 Performing emergency memory cleanup');
    
    // Aggressive memory cleanup
    MemoryManager.clearCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Force garbage collection hint
    // Note: Dart doesn't have explicit GC control, but we can clear references
    
    // Clear any large data structures
    AppCache.clearAll();
  }
  
  // Get app state info
  Map<String, dynamic> getStateInfo() {
    return {
      'current_state': _lastState?.name,
      'background_time': _backgroundTime?.toIso8601String(),
      'background_duration_minutes': _backgroundTime != null 
          ? DateTime.now().difference(_backgroundTime!).inMinutes 
          : null,
      'is_initialized': _isInitialized,
    };
  }
}

// Mixin for widgets that need lifecycle awareness
mixin AppLifecycleAware<T extends StatefulWidget> on State<T> {
  bool _isLifecycleActive = true;
  
  @override
  void initState() {
    super.initState();
    AppLifecycleManager.instance.initialize();
  }
  
  @override
  void dispose() {
    _isLifecycleActive = false;
    super.dispose();
  }
  
  // Check if widget is still active before performing operations
  bool get isLifecycleActive => _isLifecycleActive && mounted;
  
  // Safe setState that checks lifecycle
  void safeSetState(VoidCallback fn) {
    if (isLifecycleActive) {
      setState(fn);
    }
  }
  
  // Safe async operation
  Future<T> safeAsyncOperation<T>(Future<T> Function() operation) async {
    if (!isLifecycleActive) {
      throw StateError('Widget is no longer active');
    }
    
    final result = await operation();
    
    if (!isLifecycleActive) {
      throw StateError('Widget became inactive during operation');
    }
    
    return result;
  }
}
