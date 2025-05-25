import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/purchase_service.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;
  late PurchaseService _purchaseService;
  
  bool get isPremium => _isPremium;
  
  PremiumProvider() {
    _loadPremiumStatus();
    _initializePurchaseService();
  }
  
  Future<void> _initializePurchaseService() async {
    _purchaseService = PurchaseService(
      onPurchaseUpdated: (isPremium) {
        setPremium(isPremium);
      },
    );
    
    await _purchaseService.initialize();
  }
  
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    notifyListeners();
  }
  
  Future<void> setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', value);
    notifyListeners();
  }
  
  Future<bool> buyPremium() async {
    try {
      return await _purchaseService.buyPremium();
    } catch (e) {
      debugPrint('Error buying premium: $e');
      return false;
    }
  }
  
  Future<bool> restorePurchases() async {
    try {
      return await _purchaseService.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}
