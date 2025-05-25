import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/premium_provider.dart';

class AdvancedAdMobService {
  static const String publisherId = 'pub-7712832662169426';
  
  // Ad Unit IDs
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test
    }
    return 'ca-app-$publisherId/banner_home'; // Real
  }
  
  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test
    }
    return 'ca-app-$publisherId/interstitial_generate'; // Real
  }
  
  static String get rewardedAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test
    }
    return 'ca-app-$publisherId/rewarded_premium'; // Real
  }
  
  static String get nativeAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/2247696110'; // Test
    }
    return 'ca-app-$publisherId/native_templates'; // Real
  }

  // Ad Instances
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static NativeAd? _nativeAd;
  
  // Ad State Management
  static bool _isBannerLoaded = false;
  static bool _isInterstitialLoaded = false;
  static bool _isRewardedLoaded = false;
  static bool _isNativeLoaded = false;
  
  // Ad Frequency Control
  static int _interstitialShowCount = 0;
  static DateTime? _lastInterstitialShow;
  static const int maxInterstitialPerSession = 3;
  static const Duration interstitialCooldown = Duration(minutes: 2);

  /// Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadAdPreferences();
    
    // Pre-load ads
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
    _loadNativeAd();
    
    debugPrint('🎯 AdMob Service Initialized');
  }

  /// Load Banner Ad
  static void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          debugPrint('✅ Banner Ad Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          ad.dispose();
          debugPrint('❌ Banner Ad Failed: ${error.message}');
          
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadBannerAd);
        },
        onAdOpened: (ad) => _trackAdEvent('banner_opened'),
        onAdClicked: (ad) => _trackAdEvent('banner_clicked'),
      ),
    );
    
    _bannerAd?.load();
  }

  /// Load Interstitial Ad
  static Future<void> _loadInterstitialAd() async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          debugPrint('✅ Interstitial Ad Loaded');
          
          _interstitialAd?.setImmersiveMode(true);
          _setupInterstitialCallbacks();
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          debugPrint('❌ Interstitial Ad Failed: ${error.message}');
          
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }

  /// Load Rewarded Ad
  static Future<void> _loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          debugPrint('✅ Rewarded Ad Loaded');
          
          _setupRewardedCallbacks();
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
          debugPrint('❌ Rewarded Ad Failed: ${error.message}');
          
          // Retry after delay
          Future.delayed(const Duration(minutes: 2), _loadRewardedAd);
        },
      ),
    );
  }

  /// Load Native Ad
  static void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _isNativeLoaded = true;
          debugPrint('✅ Native Ad Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _isNativeLoaded = false;
          ad.dispose();
          debugPrint('❌ Native Ad Failed: ${error.message}');
          
          // Retry after delay
          Future.delayed(const Duration(minutes: 1), _loadNativeAd);
        },
        onAdOpened: (ad) => _trackAdEvent('native_opened'),
        onAdClicked: (ad) => _trackAdEvent('native_clicked'),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFFFFFFFF),
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFFFFFFFF),
          backgroundColor: const Color(0xFF1976D2),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF000000),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF666666),
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF999999),
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );
    
    _nativeAd?.load();
  }

  /// Get Banner Ad Widget
  static Widget? getBannerAdWidget() {
    if (_isBannerLoaded && _bannerAd != null) {
      return Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }
    return null;
  }

  /// Show Interstitial Ad with Smart Frequency
  static Future<bool> showInterstitialAd({
    required String placement,
    bool forceShow = false,
  }) async {
    // Check if user is premium
    // if (PremiumProvider.isPremium && !forceShow) {
    //   return false;
    // }

    // Check frequency limits
    if (!forceShow && !_canShowInterstitial()) {
      debugPrint('🚫 Interstitial blocked by frequency control');
      return false;
    }

    if (_isInterstitialLoaded && _interstitialAd != null) {
      await _interstitialAd!.show();
      _trackAdEvent('interstitial_shown', placement: placement);
      
      // Update frequency tracking
      _interstitialShowCount++;
      _lastInterstitialShow = DateTime.now();
      await _saveAdPreferences();
      
      // Reload for next time
      _loadInterstitialAd();
      
      return true;
    }
    
    debugPrint('❌ Interstitial not ready');
    return false;
  }

  /// Show Rewarded Ad
  static Future<bool> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
    required String placement,
  }) async {
    if (_isRewardedLoaded && _rewardedAd != null) {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          _trackAdEvent('rewarded_earned', placement: placement);
          onUserEarnedReward(reward);
        },
      );
      
      _trackAdEvent('rewarded_shown', placement: placement);
      
      // Reload for next time
      _loadRewardedAd();
      
      return true;
    }
    
    debugPrint('❌ Rewarded Ad not ready');
    return false;
  }

  /// Get Native Ad Widget
  static Widget? getNativeAdWidget() {
    if (_isNativeLoaded && _nativeAd != null) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    }
    return null;
  }

  /// Setup Interstitial Callbacks
  static void _setupInterstitialCallbacks() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('📺 Interstitial Ad Showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('❌ Interstitial Ad Dismissed');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Interstitial Show Failed: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
      },
    );
  }

  /// Setup Rewarded Callbacks
  static void _setupRewardedCallbacks() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('🎁 Rewarded Ad Showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('❌ Rewarded Ad Dismissed');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Rewarded Show Failed: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedLoaded = false;
      },
    );
  }

  /// Check if can show interstitial
  static bool _canShowInterstitial() {
    // Check session limit
    if (_interstitialShowCount >= maxInterstitialPerSession) {
      return false;
    }
    
    // Check cooldown
    if (_lastInterstitialShow != null) {
      final timeSinceLastShow = DateTime.now().difference(_lastInterstitialShow!);
      if (timeSinceLastShow < interstitialCooldown) {
        return false;
      }
    }
    
    return true;
  }

  /// Track Ad Events
  static void _trackAdEvent(String event, {String? placement}) {
    debugPrint('📊 Ad Event: $event ${placement != null ? '($placement)' : ''}');
    // Add your analytics tracking here
  }

  /// Load Ad Preferences
  static Future<void> _loadAdPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _interstitialShowCount = prefs.getInt('interstitial_count') ?? 0;
    
    final lastShowTimestamp = prefs.getInt('last_interstitial_show');
    if (lastShowTimestamp != null) {
      _lastInterstitialShow = DateTime.fromMillisecondsSinceEpoch(lastShowTimestamp);
    }
  }

  /// Save Ad Preferences
  static Future<void> _saveAdPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('interstitial_count', _interstitialShowCount);
    
    if (_lastInterstitialShow != null) {
      await prefs.setInt('last_interstitial_show', _lastInterstitialShow!.millisecondsSinceEpoch);
    }
  }

  /// Reset Session Data
  static void resetSession() {
    _interstitialShowCount = 0;
    _lastInterstitialShow = null;
  }

  /// Dispose All Ads
  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _nativeAd?.dispose();
    
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _nativeAd = null;
    
    _isBannerLoaded = false;
    _isInterstitialLoaded = false;
    _isRewardedLoaded = false;
    _isNativeLoaded = false;
  }

  /// Get Ad Status
  static Map<String, bool> getAdStatus() {
    return {
      'banner': _isBannerLoaded,
      'interstitial': _isInterstitialLoaded,
      'rewarded': _isRewardedLoaded,
      'native': _isNativeLoaded,
    };
  }
}
