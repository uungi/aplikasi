import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'performance_test_suite.dart';

class BenchmarkRunner {
  static const String _resultsDir = 'test_results';
  static const String _benchmarkFile = 'performance_benchmark.json';
  
  // Run performance benchmarks
  static Future<void> runBenchmarks() async {
    print('🏃‍♂️ Starting Performance Benchmarks...\n');
    
    // Create results directory
    await _createResultsDirectory();
    
    // Run current tests
    final currentResults = await PerformanceTestSuite.runAllTests();
    
    // Save current results
    await _saveResults('current', currentResults);
    
    // Compare with baseline if exists
    await _compareWithBaseline(currentResults);
    
    // Generate HTML report
    await _generateHTMLReport(currentResults);
    
    print('\n📊 Benchmark completed! Check test_results/ for detailed reports.');
  }
  
  // Set current results as baseline
  static Future<void> setBaseline() async {
    print('📏 Setting performance baseline...');
    
    final results = await PerformanceTestSuite.runAllTests();
    await _saveResults('baseline', results);
    
    print('✅ Baseline set successfully!');
  }
  
  static Future<void> _createResultsDirectory() async {
    final dir = Directory(_resultsDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
  
  static Future<void> _saveResults(String type, PerformanceTestResults results) async {
    final file = File('$_resultsDir/${type}_results.json');
    final data = _resultsToJson(results);
    await file.writeAsString(json.encode(data));
  }
  
  static Future<void> _compareWithBaseline(PerformanceTestResults current) async {
    final baselineFile = File('$_resultsDir/baseline_results.json');
    
    if (!await baselineFile.exists()) {
      print('⚠️ No baseline found. Run "setBaseline()" first to establish baseline.');
      return;
    }
    
    try {
      final baselineData = json.decode(await baselineFile.readAsString());
      final comparison = _generateComparison(baselineData, current);
      
      final comparisonFile = File('$_resultsDir/comparison_report.txt');
      await comparisonFile.writeAsString(comparison);
      
      print('\n📈 Performance Comparison:');
      print(comparison);
    } catch (e) {
      print('❌ Error comparing with baseline: $e');
    }
  }
  
  static String _generateComparison(Map<String, dynamic> baseline, PerformanceTestResults current) {
    final buffer = StringBuffer();
    buffer.writeln('PERFORMANCE COMPARISON REPORT');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('=' * 50);
    
    // Compare each category
    final categories = ['memoryTests', 'cacheTests', 'imageTests', 'aiServiceTests', 'uiTests', 'validationTests'];
    
    for (final categoryName in categories) {
      buffer.writeln('\n${categoryName.toUpperCase()}:');
      
      final baselineCategory = baseline[categoryName] as Map<String, dynamic>?;
      final currentCategory = _getCategoryResults(current, categoryName);
      
      if (baselineCategory != null && currentCategory != null) {
        for (final result in currentCategory.results) {
          final baselineValue = baselineCategory[result.name] as double?;
          if (baselineValue != null) {
            final improvement = ((baselineValue - result.average) / baselineValue) * 100;
            final status = improvement > 0 ? '🟢' : improvement < -5 ? '🔴' : '🟡';
            
            buffer.writeln('  ${result.name}:');
            buffer.writeln('    Baseline: ${baselineValue.toStringAsFixed(2)}${result.unit}');
            buffer.writeln('    Current:  ${result.average.toStringAsFixed(2)}${result.unit}');
            buffer.writeln('    Change:   $status ${improvement.toStringAsFixed(1)}%');
          }
        }
      }
    }
    
    return buffer.toString();
  }
  
  static TestCategory? _getCategoryResults(PerformanceTestResults results, String categoryName) {
    switch (categoryName) {
      case 'memoryTests': return results.memoryTests;
      case 'cacheTests': return results.cacheTests;
      case 'imageTests': return results.imageTests;
      case 'aiServiceTests': return results.aiServiceTests;
      case 'uiTests': return results.uiTests;
      case 'validationTests': return results.validationTests;
      default: return null;
    }
  }
  
  static Map<String, dynamic> _resultsToJson(PerformanceTestResults results) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'memoryTests': _categoryToJson(results.memoryTests),
      'cacheTests': _categoryToJson(results.cacheTests),
      'imageTests': _categoryToJson(results.imageTests),
      'aiServiceTests': _categoryToJson(results.aiServiceTests),
      'uiTests': _categoryToJson(results.uiTests),
      'validationTests': _categoryToJson(results.validationTests),
      'summary': results.summary,
    };
  }
  
  static Map<String, double> _categoryToJson(TestCategory category) {
    final map = <String, double>{};
    for (final result in category.results) {
      map[result.name] = result.average;
    }
    return map;
  }
  
  static Future<void> _generateHTMLReport(PerformanceTestResults results) async {
    final html = _generateHTMLContent(results);
    final file = File('$_resultsDir/performance_report.html');
    await file.writeAsString(html);
  }
  
  static String _generateHTMLContent(PerformanceTestResults results) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <title>Performance Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .category { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .test-result { margin: 10px 0; padding: 10px; background: #f9f9f9; }
        .excellent { border-left: 5px solid #4CAF50; }
        .good { border-left: 5px solid #FFC107; }
        .fair { border-left: 5px solid #FF9800; }
        .poor { border-left: 5px solid #F44336; }
        .chart { width: 100%; height: 300px; margin: 20px 0; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="header">
        <h1>🚀 Performance Test Report</h1>
        <p>Generated: ${DateTime.now()}</p>
    </div>
    
    <div class="category">
        <h2>📊 Test Results Summary</h2>
        <pre>${results.summary}</pre>
    </div>
    
    ${_generateCategoryHTML(results.memoryTests)}
    ${_generateCategoryHTML(results.cacheTests)}
    ${_generateCategoryHTML(results.imageTests)}
    ${_generateCategoryHTML(results.aiServiceTests)}
    ${_generateCategoryHTML(results.uiTests)}
    ${_generateCategoryHTML(results.validationTests)}
    
    <div class="category">
        <h2>📈 Performance Chart</h2>
        <canvas id="performanceChart" class="chart"></canvas>
    </div>
    
    <script>
        ${_generateChartScript(results)}
    </script>
</body>
</html>
''';
  }
  
  static String _generateCategoryHTML(TestCategory category) {
    final buffer = StringBuffer();
    buffer.writeln('<div class="category">');
    buffer.writeln('<h2>${category.name}</h2>');
    
    for (final result in category.results) {
      final cssClass = result.getPerformanceRating().contains('Excellent') ? 'excellent' :
                      result.getPerformanceRating().contains('Good') ? 'good' :
                      result.getPerformanceRating().contains('Fair') ? 'fair' : 'poor';
      
      buffer.writeln('<div class="test-result $cssClass">');
      buffer.writeln('<strong>${result.name}</strong><br>');
      buffer.writeln('Average: ${result.average.toStringAsFixed(2)}${result.unit}<br>');
      buffer.writeln('Range: ${result.min.toStringAsFixed(2)} - ${result.max.toStringAsFixed(2)}${result.unit}<br>');
      buffer.writeln('Rating: ${result.getPerformanceRating()}');
      buffer.writeln('</div>');
    }
    
    buffer.writeln('</div>');
    return buffer.toString();
  }
  
  static String _generateChartScript(PerformanceTestResults results) {
    final categories = [results.memoryTests, results.cacheTests, results.imageTests, 
                      results.aiServiceTests, results.uiTests, results.validationTests];
    
    final labels = <String>[];
    final data = <double>[];
    
    for (final category in categories) {
      for (final result in category.results) {
        labels.add('${category.name}: ${result.name}');
        data.add(result.average);
      }
    }
    
    return '''
const ctx = document.getElementById('performanceChart').getContext('2d');
new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ${json.encode(labels)},
        datasets: [{
            label: 'Performance (ms)',
            data: ${json.encode(data)},
            backgroundColor: 'rgba(54, 162, 235, 0.2)',
            borderColor: 'rgba(54, 162, 235, 1)',
            borderWidth: 1
        }]
    },
    options: {
        responsive: true,
        scales: {
            y: {
                beginAtZero: true
            }
        }
    }
});
''';
  }
}
