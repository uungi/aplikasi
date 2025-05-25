import 'dart:io';
import 'package:flutter/foundation.dart';

class PreBuildChecker {
  /// Comprehensive pre-build validation
  static Future<PreBuildReport> validateForBuild() async {
    final checks = <BuildCheck>[];
    
    // 1. Environment Check
    checks.add(await _checkFlutterEnvironment());
    
    // 2. Dependencies Check
    checks.add(await _checkDependencies());
    
    // 3. Assets Check
    checks.add(await _checkAssets());
    
    // 4. Configuration Check
    checks.add(await _checkConfigurations());
    
    // 5. Code Quality Check
    checks.add(await _checkCodeQuality());
    
    // 6. Platform Specific Checks
    checks.add(await _checkAndroidConfig());
    checks.add(await _checkIOSConfig());
    
    final passedChecks = checks.where((c) => c.passed).length;
    final totalChecks = checks.length;
    final score = (passedChecks / totalChecks * 100).round();
    
    return PreBuildReport(
      score: score,
      checks: checks,
      readyToBuild: score >= 95,
      criticalIssues: checks.where((c) => !c.passed && c.critical).length,
    );
  }
  
  static Future<BuildCheck> _checkFlutterEnvironment() async {
    try {
      // Check Flutter version
      final result = await Process.run('flutter', ['--version']);
      final output = result.stdout.toString();
      
      if (output.contains('3.32')) {
        return BuildCheck(
          name: 'Flutter Environment',
          passed: false,
          critical: true,
          message: '❌ FAKE Flutter version detected! Please install official Flutter.',
          recommendation: 'Download official Flutter from flutter.dev',
        );
      }
      
      if (output.contains(RegExp(r'Flutter 3\.(1[6-9]|2[0-4])'))) {
        return BuildCheck(
          name: 'Flutter Environment',
          passed: true,
          critical: false,
          message: '✅ Flutter version is compatible',
          recommendation: 'Environment is ready for build',
        );
      }
      
      return BuildCheck(
        name: 'Flutter Environment',
        passed: false,
        critical: true,
        message: '⚠️ Unsupported Flutter version',
        recommendation: 'Update to Flutter 3.16+ for best compatibility',
      );
    } catch (e) {
      return BuildCheck(
        name: 'Flutter Environment',
        passed: false,
        critical: true,
        message: '❌ Cannot detect Flutter installation',
        recommendation: 'Ensure Flutter is properly installed and in PATH',
      );
    }
  }
  
  static Future<BuildCheck> _checkDependencies() async {
    try {
      // Check pubspec.lock exists
      final lockFile = File('pubspec.lock');
      if (!await lockFile.exists()) {
        return BuildCheck(
          name: 'Dependencies',
          passed: false,
          critical: true,
          message: '❌ pubspec.lock not found',
          recommendation: 'Run flutter pub get to resolve dependencies',
        );
      }
      
      // Check for dependency conflicts
      final result = await Process.run('flutter', ['pub', 'deps']);
      if (result.exitCode != 0) {
        return BuildCheck(
          name: 'Dependencies',
          passed: false,
          critical: true,
          message: '❌ Dependency conflicts detected',
          recommendation: 'Resolve dependency conflicts in pubspec.yaml',
        );
      }
      
      return BuildCheck(
        name: 'Dependencies',
        passed: true,
        critical: false,
        message: '✅ All dependencies resolved successfully',
        recommendation: 'Dependencies are ready for build',
      );
    } catch (e) {
      return BuildCheck(
        name: 'Dependencies',
        passed: false,
        critical: true,
        message: '❌ Failed to check dependencies: $e',
        recommendation: 'Check network connection and run flutter pub get',
      );
    }
  }
  
  static Future<BuildCheck> _checkAssets() async {
    final requiredAssets = [
      '.env',
      'assets/images/',
      'assets/images/templates/',
    ];
    
    final missingAssets = <String>[];
    
    for (final asset in requiredAssets) {
      final file = File(asset);
      final directory = Directory(asset);
      
      if (!await file.exists() && !await directory.exists()) {
        missingAssets.add(asset);
      }
    }
    
    if (missingAssets.isNotEmpty) {
      return BuildCheck(
        name: 'Assets',
        passed: false,
        critical: true,
        message: '❌ Missing assets: ${missingAssets.join(", ")}',
        recommendation: 'Create missing asset files/directories',
      );
    }
    
    return BuildCheck(
      name: 'Assets',
      passed: true,
      critical: false,
      message: '✅ All required assets are present',
      recommendation: 'Assets are ready for build',
    );
  }
  
  static Future<BuildCheck> _checkConfigurations() async {
    // Check pubspec.yaml
    final pubspecFile = File('pubspec.yaml');
    if (!await pubspecFile.exists()) {
      return BuildCheck(
        name: 'Configuration',
        passed: false,
        critical: true,
        message: '❌ pubspec.yaml not found',
        recommendation: 'Ensure pubspec.yaml exists in project root',
      );
    }
    
    final content = await pubspecFile.readAsString();
    
    // Check for required fields
    if (!content.contains('name:') || !content.contains('version:')) {
      return BuildCheck(
        name: 'Configuration',
        passed: false,
        critical: true,
        message: '❌ Invalid pubspec.yaml format',
        recommendation: 'Ensure pubspec.yaml has required name and version fields',
      );
    }
    
    return BuildCheck(
      name: 'Configuration',
      passed: true,
      critical: false,
      message: '✅ Configuration files are valid',
      recommendation: 'Configuration is ready for build',
    );
  }
  
  static Future<BuildCheck> _checkCodeQuality() async {
    try {
      // Run flutter analyze
      final result = await Process.run('flutter', ['analyze']);
      
      if (result.exitCode != 0) {
        final errors = result.stdout.toString();
        return BuildCheck(
          name: 'Code Quality',
          passed: false,
          critical: false,
          message: '⚠️ Code analysis found issues',
          recommendation: 'Fix analysis issues: ${errors.split('\n').take(3).join('; ')}',
        );
      }
      
      return BuildCheck(
        name: 'Code Quality',
        passed: true,
        critical: false,
        message: '✅ Code analysis passed',
        recommendation: 'Code quality is good for build',
      );
    } catch (e) {
      return BuildCheck(
        name: 'Code Quality',
        passed: false,
        critical: false,
        message: '⚠️ Could not run code analysis',
        recommendation: 'Manually review code before building',
      );
    }
  }
  
  static Future<BuildCheck> _checkAndroidConfig() async {
    final buildGradle = File('android/app/build.gradle');
    if (!await buildGradle.exists()) {
      return BuildCheck(
        name: 'Android Configuration',
        passed: false,
        critical: true,
        message: '❌ Android build.gradle not found',
        recommendation: 'Ensure Android configuration is properly set up',
      );
    }
    
    final content = await buildGradle.readAsString();
    
    // Check for required configurations
    if (!content.contains('compileSdkVersion') || !content.contains('minSdkVersion')) {
      return BuildCheck(
        name: 'Android Configuration',
        passed: false,
        critical: true,
        message: '❌ Invalid Android configuration',
        recommendation: 'Ensure compileSdkVersion and minSdkVersion are set',
      );
    }
    
    return BuildCheck(
      name: 'Android Configuration',
      passed: true,
      critical: false,
      message: '✅ Android configuration is valid',
      recommendation: 'Android build configuration is ready',
    );
  }
  
  static Future<BuildCheck> _checkIOSConfig() async {
    final iosDir = Directory('ios');
    if (!await iosDir.exists()) {
      return BuildCheck(
        name: 'iOS Configuration',
        passed: false,
        critical: false,
        message: '⚠️ iOS directory not found',
        recommendation: 'iOS configuration not required for Android-only builds',
      );
    }
    
    final infoPlist = File('ios/Runner/Info.plist');
    if (!await infoPlist.exists()) {
      return BuildCheck(
        name: 'iOS Configuration',
        passed: false,
        critical: false,
        message: '⚠️ iOS Info.plist not found',
        recommendation: 'Ensure iOS configuration is complete for iOS builds',
      );
    }
    
    return BuildCheck(
      name: 'iOS Configuration',
      passed: true,
      critical: false,
      message: '✅ iOS configuration is present',
      recommendation: 'iOS build configuration is ready',
    );
  }
}

class BuildCheck {
  final String name;
  final bool passed;
  final bool critical;
  final String message;
  final String recommendation;
  
  BuildCheck({
    required this.name,
    required this.passed,
    required this.critical,
    required this.message,
    required this.recommendation,
  });
}

class PreBuildReport {
  final int score;
  final List<BuildCheck> checks;
  final bool readyToBuild;
  final int criticalIssues;
  
  PreBuildReport({
    required this.score,
    required this.checks,
    required this.readyToBuild,
    required this.criticalIssues,
  });
  
  String get grade {
    if (score >= 95) return 'A+ (Excellent)';
    if (score >= 90) return 'A (Very Good)';
    if (score >= 85) return 'B+ (Good)';
    if (score >= 80) return 'B (Fair)';
    if (score >= 70) return 'C (Needs Improvement)';
    return 'F (Critical Issues)';
  }
}
