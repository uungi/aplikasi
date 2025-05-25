import 'dart:io';
import 'iap_service.dart';
import 'google_play_iap_service.dart';
import 'amazon_iap_service.dart';
import '../utils/platform_detector.dart';

class IAPServiceFactory {
  static Future<IAPService> getService({
    PurchaseUpdatedCallback? onPurchaseUpdated,
  }) async {
    if (Platform.isIOS) {
      // Untuk iOS, gunakan Google Play IAP Service (yang support iOS via in_app_purchase)
      return GooglePlayIAPService(onPurchaseUpdated: onPurchaseUpdated);
    }
    
    if (Platform.isAndroid) {
      final isAmazon = await PlatformDetector.isAmazonDevice();
      
      if (isAmazon) {
        return AmazonIAPService(onPurchaseUpdated: onPurchaseUpdated);
      } else {
        return GooglePlayIAPService(onPurchaseUpdated: onPurchaseUpdated);
      }
    }
    
    throw UnsupportedError('Platform not supported');
  }
}
