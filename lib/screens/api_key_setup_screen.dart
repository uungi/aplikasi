```dart file="lib/utils/app_logger.dart"
import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _tag = 'AIResumeGenerator';
  
  // Log levels
  static const int _levelDebug = 0;
  static const int _levelInfo = 1;
  static const int _levelWarning = 2;
  static const int _levelError = 3;
  
  static int _currentLogLevel = kDebugMode ? _levelDebug : _levelInfo;
  
  // Set log level
  static void setLogLevel(int level) {
    _currentLogLevel = level;
  }
  
  // Debug logging
  static void debug(String message, [String? tag]) {
    if (_currentLogLevel &lt;= _levelDebug) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }
  
  // Info logging
  static void info(String message, [String? tag]) {
    if (_currentLogLevel &lt;= _levelInfo) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }
  
  // Warning logging
  static void warning(String message, [String? tag]) {
    if (_currentLogLevel &lt;= _levelWarning) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }
  
  // Error logging
  static void error(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    if (_currentLogLevel &lt;= _levelError) {
      debugPrint('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        debugPrint('[$_tag${tag != null ? ':$tag' : ''}] Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$_tag${tag != null ? ':$tag' : ''}] Stack trace: $stackTrace');
      }
    }
    
    // In production, you might want to send to crash analytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
  
  // API call logging
  static void apiCall(String method, String url, [Map<String, dynamic>? data]) {
    debug('API $method: $url${data != null ? ' with data: $data' : ''}', 'API');
  }
  
  // API response logging
  static void apiResponse(String url, int statusCode, [String? response]) {
    if (statusCode >= 200 && statusCode &lt; 300) {
      debug('API Response: $url - $statusCode${response != null ? ' - $response' : ''}', 'API');
    } else {
      warning('API Error: $url - $statusCode${response != null ? ' - $response' : ''}', 'API');
    }
  }
  
  // User action logging
  static void userAction(String action, [Map<String, dynamic>? data]) {
    info('User Action: $action${data != null ? ' - $data' : ''}', 'USER');
  }
  
  // Performance logging
  static void performance(String operation, Duration duration) {
    info('Performance: $operation took ${duration.inMilliseconds}ms', 'PERF');
  }
  
  // Security logging
  static void security(String event, [Map<String, dynamic>? data]) {
    warning('Security Event: $event${data != null ? ' - $data' : ''}', 'SECURITY');
  }
}

// Performance tracker utility
class PerformanceTracker {
  static final Map<String, DateTime> _startTimes = {};
  
  static void start(String operation) {
    _startTimes[operation] = DateTime.now();
    AppLogger.debug('Started tracking: $operation', 'PERF');
  }
  
  static void end(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      AppLogger.performance(operation, duration);
      _startTimes.remove(operation);
    } else {
      AppLogger.warning('Attempted to end tracking for unknown operation: $operation', 'PERF');
    }
  }
  
  static void endAndLog(String operation, String message) {
    end(operation);
    AppLogger.info(message);
  }
}
