#!/bin/bash

echo "🚀 Starting Performance Test Suite"
echo "=================================="

# Create test results directory
mkdir -p test_results

# Run performance tests
echo "📊 Running performance tests..."
flutter test test/performance/performance_test_runner.dart

# Run load tests
echo "🔥 Running load tests..."
flutter test test/performance/load_test.dart

# Run validation performance tests
echo "✅ Running validation performance tests..."
flutter test test/performance/validation_performance_test.dart

# Generate performance report
echo "📈 Generating performance report..."
flutter test test/performance/benchmark_runner.dart

echo ""
echo "✅ Performance tests completed!"
echo "📊 Check test_results/ directory for detailed reports"
echo "🌐 Open test_results/performance_report.html for visual report"
