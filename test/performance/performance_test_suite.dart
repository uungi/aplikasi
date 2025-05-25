import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:visha2/utils/performance_monitor.dart';
import 'package:visha2/utils/app_cache.dart';
import 'package:visha2/utils/memory_manager.dart';
import 'package:visha2/utils/image_optimizer.dart';
import 'package:visha2/services/ai_service.dart';
import 'package:visha2/models/user_input.dart';
import 'dart:math';

class PerformanceTestSuite {
  static const int _testIterations = 100;
  static const int _warmupIterations = 10;
  
  // Run all performance tests
  static Future<PerformanceTestResults> runAllTests() async {
    print('🚀 Starting Performance Test Suite...\n');
    
    final results = PerformanceTestResults();
    
    // Initialize systems
    await _initializeSystems();
    
    // Run individual test categories
    results.memoryTests = await _runMemoryTests();
    results.cacheTests = await _runCacheTests();
    results.imageTests = await _runImageTests();
    results.aiServiceTests = await _runAIServiceTests();
    results.uiTests = await _runUITests();
    results.validationTests = await _runValidationTests();
    
    // Generate summary
    results.generateSummary();
    
    print('\n✅ Performance Test Suite Completed!');
    return results;
  }
  
  static Future<void> _initializeSystems() async {
    print('🔧 Initializing test systems...');
    await AppCache.initialize();
    MemoryManager.initialize();
    ImageOptimizer.configureImageCache(maximumSize: 50, maximumSizeBytes: 25 * 1024 * 1024);
    PerformanceMonitor.clearData();
  }
  
  // Memory Performance Tests
  static Future<TestCategory> _runMemoryTests() async {
    print('🧠 Running Memory Performance Tests...');
    final category = TestCategory('Memory Tests');
    
    // Test 1: Memory allocation and cleanup
    final memoryTest = await _measureOperation('memory_allocation', () async {
      final data = List.generate(1000, (i) => 'Test data $i' * 100);
      await Future.delayed(const Duration(milliseconds: 10));
      data.clear();
    });
    category.addResult('Memory Allocation/Cleanup', memoryTest);
    
    // Test 2: Memory manager efficiency
    final managerTest = await _measureOperation('memory_manager', () async {
      final manager = MemoryManager();
      for (int i = 0; i < 100; i++) {
        manager.trackResource('test_$i', () => 'resource_$i');
      }
      manager.cleanup();
    });
    category.addResult('Memory Manager', managerTest);
    
    // Test 3: Memory pressure simulation
    final pressureTest = await _measureOperation('memory_pressure', () async {
      // Simulate memory pressure
      final largeData = List.generate(10000, (i) => List.filled(100, i));
      await MemoryManager.handleMemoryPressure();
      largeData.clear();
    });
    category.addResult('Memory Pressure Handling', pressureTest);
    
    return category;
  }
  
  // Cache Performance Tests
  static Future<TestCategory> _runCacheTests() async {
    print('💾 Running Cache Performance Tests...');
    final category = TestCategory('Cache Tests');
    
    // Test 1: Memory cache performance
    final memoryCacheTest = await _measureOperation('memory_cache', () async {
      for (int i = 0; i < 1000; i++) {
        AppCache.setMemoryCache('test_$i', 'value_$i');
        AppCache.getMemoryCache<String>('test_$i');
      }
    });
    category.addResult('Memory Cache Operations', memoryCacheTest);
    
    // Test 2: Persistent cache performance
    final persistentCacheTest = await _measureOperation('persistent_cache', () async {
      for (int i = 0; i < 100; i++) {
        await AppCache.setPersistentCache('persistent_$i', 'value_$i');
        await AppCache.getPersistentCache<String>('persistent_$i');
      }
    });
    category.addResult('Persistent Cache Operations', persistentCacheTest);
    
    // Test 3: Cache hit rate
    final hitRateTest = await _measureCacheHitRate();
    category.addResult('Cache Hit Rate', hitRateTest);
    
    return category;
  }
  
  // Image Performance Tests
  static Future<TestCategory> _runImageTests() async {
    print('🖼️ Running Image Performance Tests...');
    final category = TestCategory('Image Tests');
    
    // Test 1: Image optimization
    final optimizationTest = await _measureOperation('image_optimization', () async {
      for (int i = 0; i < 50; i++) {
        ImageOptimizer.optimizeImageProvider(
          'assets/images/test_image.png',
          width: 200,
          height: 200,
        );
      }
    });
    category.addResult('Image Optimization', optimizationTest);
    
    // Test 2: Thumbnail generation
    final thumbnailTest = await _measureOperation('thumbnail_generation', () async {
      for (int i = 0; i < 20; i++) {
        await ImageOptimizer.createThumbnail('assets/images/test_image.png');
      }
    });
    category.addResult('Thumbnail Generation', thumbnailTest);
    
    return category;
  }
  
  // AI Service Performance Tests
  static Future<TestCategory> _runAIServiceTests() async {
    print('🤖 Running AI Service Performance Tests...');
    final category = TestCategory('AI Service Tests');
    
    // Test 1: Input processing
    final inputProcessingTest = await _measureOperation('input_processing', () async {
      final input = UserInput(
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        position: 'Software Engineer',
        template: 'professional',
        contact: 'john@example.com',
      );
      
      // Simulate input processing
      await Future.delayed(const Duration(milliseconds: 50));
    });
    category.addResult('Input Processing', inputProcessingTest);
    
    // Test 2: Template processing
    final templateTest = await _measureOperation('template_processing', () async {
      // Simulate template processing
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
    });
    category.addResult('Template Processing', templateTest);
    
    return category;
  }
  
  // UI Performance Tests
  static Future<TestCategory> _runUITests() async {
    print('🎨 Running UI Performance Tests...');
    final category = TestCategory('UI Tests');
    
    // Test 1: Widget build performance
    final buildTest = await _measureOperation('widget_build', () async {
      // Simulate widget building
      for (int i = 0; i < 1000; i++) {
        final widget = Container(
          key: ValueKey(i),
          child: Text('Item $i'),
        );
        // Simulate build time
        await Future.delayed(const Duration(microseconds: 100));
      }
    });
    category.addResult('Widget Build Performance', buildTest);
    
    // Test 2: List scrolling performance
    final scrollTest = await _measureOperation('list_scrolling', () async {
      // Simulate list scrolling
      for (int i = 0; i < 500; i++) {
        await Future.delayed(const Duration(microseconds: 200));
      }
    });
    category.addResult('List Scrolling Performance', scrollTest);
    
    return category;
  }
  
  // Validation Performance Tests
  static Future<TestCategory> _runValidationTests() async {
    print('✅ Running Validation Performance Tests...');
    final category = TestCategory('Validation Tests');
    
    // Test 1: Form validation performance
    final validationTest = await _measureOperation('form_validation', () async {
      for (int i = 0; i < 1000; i++) {
        // Simulate validation
        final email = 'user$i@example.com';
        final isValid = email.contains('@') && email.contains('.');
        await Future.delayed(const Duration(microseconds: 50));
      }
    });
    category.addResult('Form Validation', validationTest);
    
    return category;
  }
  
  // Helper method to measure operation performance
  static Future<TestResult> _measureOperation(String name, Future<void> Function() operation) async {
    final results = <int>[];
    
    // Warmup
    for (int i = 0; i < _warmupIterations; i++) {
      await operation();
    }
    
    // Actual measurements
    for (int i = 0; i < _testIterations; i++) {
      final stopwatch = Stopwatch()..start();
      await operation();
      stopwatch.stop();
      results.add(stopwatch.elapsedMicroseconds);
    }
    
    return TestResult.fromMicroseconds(name, results);
  }
  
  // Measure cache hit rate
  static Future<TestResult> _measureCacheHitRate() async {
    int hits = 0;
    int misses = 0;
    
    // Populate cache
    for (int i = 0; i < 100; i++) {
      AppCache.setMemoryCache('hit_test_$i', 'value_$i');
    }
    
    // Test cache hits and misses
    for (int i = 0; i < 200; i++) {
      final value = AppCache.getMemoryCache<String>('hit_test_$i');
      if (value != null) {
        hits++;
      } else {
        misses++;
      }
    }
    
    final hitRate = (hits / (hits + misses)) * 100;
    return TestResult('Cache Hit Rate', hitRate, '%', 0, hitRate, hitRate);
  }
}

class PerformanceTestResults {
  late TestCategory memoryTests;
  late TestCategory cacheTests;
  late TestCategory imageTests;
  late TestCategory aiServiceTests;
  late TestCategory uiTests;
  late TestCategory validationTests;
  
  String summary = '';
  
  void generateSummary() {
    final buffer = StringBuffer();
    buffer.writeln('\n📊 PERFORMANCE TEST RESULTS SUMMARY');
    buffer.writeln('=' * 50);
    
    final categories = [memoryTests, cacheTests, imageTests, aiServiceTests, uiTests, validationTests];
    
    for (final category in categories) {
      buffer.writeln('\n${category.name}:');
      for (final result in category.results) {
        buffer.writeln('  ${result.name}: ${result.average.toStringAsFixed(2)}${result.unit} (${result.getPerformanceRating()})');
      }
    }
    
    // Overall performance score
    final overallScore = _calculateOverallScore(categories);
    buffer.writeln('\n🏆 Overall Performance Score: ${overallScore.toStringAsFixed(1)}/100');
    buffer.writeln(_getPerformanceGrade(overallScore));
    
    summary = buffer.toString();
    print(summary);
  }
  
  double _calculateOverallScore(List<TestCategory> categories) {
    double totalScore = 0;
    int totalTests = 0;
    
    for (final category in categories) {
      for (final result in category.results) {
        totalScore += result.getScoreOutOf100();
        totalTests++;
      }
    }
    
    return totalTests > 0 ? totalScore / totalTests : 0;
  }
  
  String _getPerformanceGrade(double score) {
    if (score >= 90) return '🥇 Excellent Performance!';
    if (score >= 80) return '🥈 Good Performance';
    if (score >= 70) return '🥉 Fair Performance';
    if (score >= 60) return '⚠️ Needs Improvement';
    return '❌ Poor Performance';
  }
}

class TestCategory {
  final String name;
  final List<TestResult> results = [];
  
  TestCategory(this.name);
  
  void addResult(String testName, TestResult result) {
    results.add(result);
  }
}

class TestResult {
  final String name;
  final double average;
  final String unit;
  final double min;
  final double max;
  final double median;
  
  TestResult(this.name, this.average, this.unit, this.min, this.max, this.median);
  
  factory TestResult.fromMicroseconds(String name, List<int> microseconds) {
    microseconds.sort();
    final average = microseconds.reduce((a, b) => a + b) / microseconds.length;
    final min = microseconds.first.toDouble();
    final max = microseconds.last.toDouble();
    final median = microseconds[microseconds.length ~/ 2].toDouble();
    
    return TestResult(name, average / 1000, 'ms', min / 1000, max / 1000, median / 1000);
  }
  
  String getPerformanceRating() {
    if (unit == 'ms') {
      if (average < 1) return '🟢 Excellent';
      if (average < 5) return '🟡 Good';
      if (average < 10) return '🟠 Fair';
      return '🔴 Poor';
    } else if (unit == '%') {
      if (average > 90) return '🟢 Excellent';
      if (average > 80) return '🟡 Good';
      if (average > 70) return '🟠 Fair';
      return '🔴 Poor';
    }
    return '⚪ Unknown';
  }
  
  double getScoreOutOf100() {
    if (unit == 'ms') {
      // Lower is better for milliseconds
      if (average < 1) return 100;
      if (average < 5) return 80;
      if (average < 10) return 60;
      if (average < 20) return 40;
      return 20;
    } else if (unit == '%') {
      // Higher is better for percentages
      return average;
    }
    return 50; // Default score
  }
}
