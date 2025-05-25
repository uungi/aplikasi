class BuildConfig {
  // App Information
  static const String appName = 'AI Resume Generator';
  static const String packageName = 'com.visha.airesume';
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  
  // Build Configuration
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool isDebug = !isProduction;
  
  // API Configuration
  static const String baseUrl = isProduction 
    ? 'https://api.airesume.com' 
    : 'https://dev-api.airesume.com';
  
  // AdMob Configuration
  static const String androidAdMobAppId = 'ca-app-pub-YOUR_PUBLISHER_ID~YOUR_APP_ID';
  static const String iosAdMobAppId = 'ca-app-pub-YOUR_PUBLISHER_ID~YOUR_APP_ID';
  
  // Test Ad Unit IDs (for development)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  // Production Ad Unit IDs (replace with your actual IDs)
  static const String prodBannerAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/BANNER_AD_UNIT';
  static const String prodInterstitialAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/INTERSTITIAL_AD_UNIT';
  static const String prodRewardedAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/REWARDED_AD_UNIT';
  
  // Get current ad unit IDs based on build mode
  static String get bannerAdUnitId => isProduction ? prodBannerAdUnitId : testBannerAdUnitId;
  static String get interstitialAdUnitId => isProduction ? prodInterstitialAdUnitId : testInterstitialAdUnitId;
  static String get rewardedAdUnitId => isProduction ? prodRewardedAdUnitId : testRewardedAdUnitId;
  
  // In-App Purchase Product IDs
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumYearlyId = 'premium_yearly';
  static const String premiumLifetimeId = 'premium_lifetime';
  
  // Feature Flags
  static const bool enableAnalytics = isProduction;
  static const bool enableCrashReporting = isProduction;
  static const bool enablePerformanceMonitoring = true;
}
