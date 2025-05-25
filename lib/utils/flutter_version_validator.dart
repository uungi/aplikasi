import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FlutterVersionValidator {
  // Official Flutter versions yang didukung
  static const List<String> supportedVersions = [
    '3.16.0', '3.16.1', '3.16.2', '3.16.3', '3.16.4', '3.16.5',
    '3.17.0', '3.17.1', '3.17.2', '3.17.3', '3.17.4', '3.17.5',
    '3.18.0', '3.18.1', '3.18.2', '3.18.3', '3.18.4', '3.18.5',
    '3.19.0', '3.19.1', '3.19.2', '3.19.3', '3.19.4', '3.19.5', '3.19.6',
    '3.20.0', '3.20.1', '3.20.2', '3.20.3', '3.20.4', '3.20.5', '3.20.6',
    '3.21.0', '3.21.1', '3.21.2', '3.21.3', '3.21.4', '3.21.5',
    '3.22.0', '3.22.1', '3.22.2', '3.22.3',
    '3.23.0', '3.23.1', '3.23.2', '3.23.3',
    '3.24.0', '3.24.1', '3.24.2', '3.24.3', '3.24.4', '3.24.5',
    '3.25.0', // Future release
    '3.26.0', // Future release
    '3.27.0', // Beta channel
  ];
  
  // Versi yang TIDAK VALID (fake/unofficial)
  static const List<String> invalidVersions = [
    '3.32.0', '3.32.1', '3.32.2', // FAKE VERSIONS
    '3.30.0', '3.31.0', '3.33.0', // FAKE VERSIONS
    '4.0.0', '4.1.0', // Future major version
  ];
  
  /// Validate Flutter version
  static ValidationResult validateFlutterVersion(String version) {
    // Remove any suffixes like -stable, -beta, etc.
    final cleanVersion = version.split('-').first;
    
    if (invalidVersions.contains(cleanVersion)) {
      return ValidationResult(
        isValid: false,
        isOfficial: false,
        message: '⚠️ FAKE VERSION DETECTED! Flutter $version is not official!',
        recommendation: 'Please install official Flutter from flutter.dev',
        securityRisk: true,
      );
    }
    
    if (supportedVersions.contains(cleanVersion)) {
      return ValidationResult(
        isValid: true,
        isOfficial: true,
        message: '✅ Official Flutter version detected',
        recommendation: 'Your Flutter version is supported',
        securityRisk: false,
      );
    }
    
    // Unknown version (might be newer official version)
    return ValidationResult(
      isValid: false,
      isOfficial: false,
      message: '⚠️ Unknown Flutter version: $version',
      recommendation: 'Please verify this is an official Flutter release',
      securityRisk: true,
    );
  }
  
  /// Get recommended Flutter version
  static String getRecommendedVersion() {
    return '3.24.5'; // Latest stable
  }
  
  /// Check if app is compatible with current Flutter version
  static Future<CompatibilityCheck> checkCompatibility() async {
    try {
      // Get Flutter version from environment
      const flutterVersion = String.fromEnvironment('FLUTTER_VERSION', defaultValue: 'unknown');
      
      final validation = validateFlutterVersion(flutterVersion);
      
      return CompatibilityCheck(
        currentVersion: flutterVersion,
        validation: validation,
        appCompatible: validation.isValid && validation.isOfficial,
        buildSafe: validation.isValid && !validation.securityRisk,
      );
    } catch (e) {
      return CompatibilityCheck(
        currentVersion: 'unknown',
        validation: ValidationResult(
          isValid: false,
          isOfficial: false,
          message: 'Failed to detect Flutter version',
          recommendation: 'Please check your Flutter installation',
          securityRisk: true,
        ),
        appCompatible: false,
        buildSafe: false,
      );
    }
  }
}

class ValidationResult {
  final bool isValid;
  final bool isOfficial;
  final String message;
  final String recommendation;
  final bool securityRisk;
  
  ValidationResult({
    required this.isValid,
    required this.isOfficial,
    required this.message,
    required this.recommendation,
    required this.securityRisk,
  });
}

class CompatibilityCheck {
  final String currentVersion;
  final ValidationResult validation;
  final bool appCompatible;
  final bool buildSafe;
  
  CompatibilityCheck({
    required this.currentVersion,
    required this.validation,
    required this.appCompatible,
    required this.buildSafe,
  });
}
