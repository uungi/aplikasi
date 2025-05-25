import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<int>> _durations = {};
  static final List<MemorySnapshot> _memorySnapshots = [];
  
  // Start tracking an operation
  static void startOperation(String operationName) {
    _startTimes[operationName] = DateTime.now();
    developer.Timeline.startSync(operationName);
  }
  
  // End tracking an operation
  static void endOperation(String operationName) {
    final startTime = _startTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      final durationMs = duration.inMilliseconds;
      
      // Store duration for analytics
      _durations.putIfAbsent(operationName, () => []).add(durationMs);
      
      // Log if operation is slow
      if (durationMs > 1000) {
        debugPrint('⚠️ Slow operation: $operationName took ${durationMs}ms');
      } else if (durationMs > 500) {
        debugPrint('⏱️ Operation: $operationName took ${durationMs}ms');
      }
      
      _startTimes.remove(operationName);
      developer.Timeline.finishSync();
    }
  }
  
  // Track memory usage
  static Future<void> trackMemoryUsage(String context) async {
    if (kDebugMode) {
      try {
        final memoryInfo = await _getMemoryInfo();
        _memorySnapshots.add(MemorySnapshot(
          context: context,
          timestamp: DateTime.now(),
          usedMemoryMB: memoryInfo['used'] ?? 0,
          totalMemoryMB: memoryInfo['total'] ?? 0,
        ));
        
        // Keep only last 100 snapshots
        if (_memorySnapshots.length > 100) {
          _memorySnapshots.removeAt(0);
        }
        
        // Log high memory usage
        final usedMB = memoryInfo['used'] ?? 0;
        if (usedMB > 200) {
          debugPrint('🔴 High memory usage: ${usedMB}MB in $context');
        } else if (usedMB > 100) {
          debugPrint('🟡 Memory usage: ${usedMB}MB in $context');
        }
      } catch (e) {
        debugPrint('Error tracking memory: $e');
      }
    }
  }
  
  // Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    for (final entry in _durations.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final avg = durations.reduce((a, b) => a + b) / durations.length;
        final max = durations.reduce((a, b) => a > b ? a : b);
        final min = durations.reduce((a, b) => a < b ? a : b);
        
        stats[entry.key] = {
          'average_ms': avg.round(),
          'max_ms': max,
          'min_ms': min,
          'count': durations.length,
        };
      }
    }
    
    return stats;
  }
  
  // Get memory statistics
  static Map<String, dynamic> getMemoryStats() {
    if (_memorySnapshots.isEmpty) return {};
    
    final usedMemories = _memorySnapshots.map((s) => s.usedMemoryMB).toList();
    final avgMemory = usedMemories.reduce((a, b) => a + b) / usedMemories.length;
    final maxMemory = usedMemories.reduce((a, b) => a > b ? a : b);
    final minMemory = usedMemories.reduce((a, b) => a < b ? a : b);
    
    return {
      'average_mb': avgMemory.round(),
      'max_mb': maxMemory,
      'min_mb': minMemory,
      'snapshots_count': _memorySnapshots.length,
      'latest_mb': _memorySnapshots.last.usedMemoryMB,
    };
  }
  
  // Clear all performance data
  static void clearData() {
    _startTimes.clear();
    _durations.clear();
    _memorySnapshots.clear();
  }
  
  // Get memory info from platform
  static Future<Map<String, int>> _getMemoryInfo() async {
    try {
      const platform = MethodChannel('performance_monitor');
      final result = await platform.invokeMethod('getMemoryInfo');
      return Map<String, int>.from(result);
    } catch (e) {
      // Fallback for platforms that don't support memory info
      return {'used': 0, 'total': 0};
    }
  }
  
  // Log performance summary
  static void logPerformanceSummary() {
    if (kDebugMode) {
      debugPrint('\n📊 Performance Summary:');
      final perfStats = getPerformanceStats();
      for (final entry in perfStats.entries) {
        final stats = entry.value;
        debugPrint('  ${entry.key}: avg=${stats['average_ms']}ms, max=${stats['max_ms']}ms, count=${stats['count']}');
      }
      
      final memStats = getMemoryStats();
      if (memStats.isNotEmpty) {
        debugPrint('  Memory: avg=${memStats['average_mb']}MB, max=${memStats['max_mb']}MB, current=${memStats['latest_mb']}MB');
      }
      debugPrint('');
    }
  }
}

class MemorySnapshot {
  final String context;
  final DateTime timestamp;
  final int usedMemoryMB;
  final int totalMemoryMB;
  
  MemorySnapshot({
    required this.context,
    required this.timestamp,
    required this.usedMemoryMB,
    required this.totalMemoryMB,
  });
}

// Extension for easy performance tracking
extension PerformanceTracking on Future<T> Function() {
  Future<T> trackPerformance<T>(String operationName) async {
    PerformanceMonitor.startOperation(operationName);
    try {
      final result = await this();
      return result;
    } finally {
      PerformanceMonitor.endOperation(operationName);
    }
  }
}
