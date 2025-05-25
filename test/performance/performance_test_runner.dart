import 'package:flutter_test/flutter_test.dart';
import 'performance_test_suite.dart';
import 'benchmark_runner.dart';

void main() {
  group('Performance Tests', () {
    setUpAll(() async {
      // Initialize test environment
      TestWidgetsFlutterBinding.ensureInitialized();
    });
    
    test('Run Complete Performance Test Suite', () async {
      final results = await PerformanceTestSuite.runAllTests();
      
      // Verify all tests completed
      expect(results.memoryTests.results.isNotEmpty, true);
      expect(results.cacheTests.results.isNotEmpty, true);
      expect(results.imageTests.results.isNotEmpty, true);
      expect(results.aiServiceTests.results.isNotEmpty, true);
      expect(results.uiTests.results.isNotEmpty, true);
      expect(results.validationTests.results.isNotEmpty, true);
      
      // Verify performance thresholds
      for (final result in results.memoryTests.results) {
        expect(result.average, lessThan(100), reason: 'Memory operations should be under 100ms');
      }
      
      for (final result in results.cacheTests.results) {
        expect(result.average, lessThan(50), reason: 'Cache operations should be under 50ms');
      }
      
      print('\n✅ All performance tests passed!');
    });
    
    test('Set Performance Baseline', () async {
      await BenchmarkRunner.setBaseline();
      expect(true, true); // Test passes if no exceptions
    });
    
    test('Run Performance Benchmarks', () async {
      await BenchmarkRunner.runBenchmarks();
      expect(true, true); // Test passes if no exceptions
    });
  });
}
