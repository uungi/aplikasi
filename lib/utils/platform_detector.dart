import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PlatformDetector {
  static Future<bool> isAmazonDevice() async {
    if (!Platform.isAndroid) return false;
    
    try {
      // Metode 1: Cek manufacturer
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final manufacturer = androidInfo.manufacturer.toLowerCase();
      
      if (manufacturer.contains('amazon')) {
        return true;
      }
      
      // Metode 2: Cek installer package
      final packageInfo = await PackageInfo.fromPlatform();
      final installerPackage = await _getInstallerPackageName(packageInfo.packageName);
      
      if (installerPackage != null) {
        return installerPackage.contains('amazon') || 
               installerPackage.contains('underground');
      }
      
      // Metode 3: Cek keberadaan Amazon App Store
      return await _isAmazonAppStoreInstalled();
    } catch (e) {
      print('Error detecting Amazon device: $e');
      return false; // Default ke Google Play jika deteksi gagal
    }
  }
  
  static Future<String?> _getInstallerPackageName(String packageName) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      // Ini adalah pendekatan sederhana, dalam implementasi nyata
      // Anda perlu menggunakan method channel untuk mengakses
      // PackageManager.getInstallerPackageName
      return packageInfo.installerStore;
    } catch (e) {
      print('Error getting installer package: $e');
      return null;
    }
  }
  
  static Future<bool> _isAmazonAppStoreInstalled() async {
    try {
      // Dalam implementasi nyata, Anda perlu menggunakan method channel
      // untuk memeriksa apakah Amazon App Store terinstal
      // Ini adalah pendekatan sederhana
      return false;
    } catch (e) {
      return false;
    }
  }
}
