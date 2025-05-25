import 'dart:io';
import 'package:flutter/foundation.dart';

class BuildCompatibilityHelper {
  /// Platform-specific build configurations
  static const Map<String, Map<String, dynamic>> platformConfigs = {
    'android': {
      'minSdkVersion': 21,
      'compileSdkVersion': 34,
      'targetSdkVersion': 34,
      'kotlinVersion': '1.9.10',
      'gradleVersion': '8.3',
      'agpVersion': '8.1.2',
    },
    'ios': {
      'minIosVersion': '12.0',
      'xcodeVersion': '15.0',
      'swiftVersion': '5.9',
    },
    'windows': {
      'minWindowsVersion': '10.0.17763.0',
      'visualStudioVersion': '2022',
      'cmakeVersion': '3.21',
    },
    'macos': {
      'minMacosVersion': '10.14',
      'xcodeVersion': '15.0',
    },
    'linux': {
      'minLinuxVersion': 'Ubuntu 18.04',
      'gccVersion': '9.0',
      'cmakeVersion': '3.16',
    },
  };
  
  /// Check platform compatibility
  static bool isPlatformSupported(String platform) {
    return platformConfigs.containsKey(platform.toLowerCase());
  }
  
  /// Get build requirements for platform
  static Map<String, dynamic>? getBuildRequirements(String platform) {
    return platformConfigs[platform.toLowerCase()];
  }
  
  /// Generate platform-specific build instructions
  static String getBuildInstructions(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return '''
# Android Build Instructions
1. Ensure Android SDK 34 is installed
2. Update Kotlin to 1.9.10+
3. Use Gradle 8.3+
4. Run: flutter build apk --release
   Or: flutter build appbundle --release
''';
      
      case 'ios':
        return '''
# iOS Build Instructions
1. Ensure Xcode 15.0+ is installed
2. Update iOS deployment target to 12.0+
3. Run: flutter build ios --release
4. Archive in Xcode for App Store
''';
      
      case 'windows':
        return '''
# Windows Build Instructions
1. Ensure Visual Studio 2022 is installed
2. Install Windows 10 SDK (10.0.17763.0+)
3. Run: flutter build windows --release
''';
      
      default:
        return 'Platform not supported yet.';
    }
  }
}
