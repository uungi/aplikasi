import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'iap_service.dart';
import 'iap_service_factory.dart';

class PurchaseService {
  static const String _premiumKey = 'is_premium';
  final PurchaseUpdatedCallback? onPurchaseUpdated;
  late IAPService _iapService;
  bool _isInitialized = false;
  
  PurchaseService({this.onPurchaseUpdated});
  
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _iapService = await IAPServiceFactory.getService(
        onPurchaseUpdated: (isPremium) {
          if (isPremium) {
            _savePremiumStatus(true);
          }
          
          if (onPurchaseUpdated != null) {
            onPurchaseUpdated!(isPremium);
          }
        },
      );
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing purchase service: $e');
      return false;
    }
  }
  
  Future<bool> buyPremium() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      return await _iapService.buyProduct('ai_resume_premium');
    } catch (e) {
      print('Error buying premium: $e');
      return false;
    }
  }
  
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      final result = await _iapService.restorePurchases();
      
      // Check if premium is purchased
      final isPremium = await _iapService.isPurchased('ai_resume_premium');
      if (isPremium) {
        await _savePremiumStatus(true);
        
        if (onPurchaseUpdated != null) {
          onPurchaseUpdated!(true);
        }
      }
      
      return result;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
  
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }
  
  Future<void> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
  }
  
  void dispose() {
    if (_isInitialized) {
      _iapService.dispose();
    }
  }
}
