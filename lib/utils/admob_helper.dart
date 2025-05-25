import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobHelper {
  // Real publisher ID
  static const String publisherId = 'pub-7712832662169426';
  
  // Test IDs for development, real IDs for production
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    }
    return 'ca-app-$publisherId/banner_ad_unit'; // Replace with your real banner ad unit ID
  }
  
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    }
    return 'ca-app-$publisherId/interstitial_ad_unit'; // Replace with your real interstitial ad unit ID
  }

  // Get a banner ad
  static BannerAd getBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
  }

  // Load an interstitial ad
  static Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;
    
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            interstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad failed to load: ${error.message}');
          },
        ),
      );
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
    }
    
    return interstitialAd;
  }
}
