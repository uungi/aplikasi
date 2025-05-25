import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseService {
  static const String premiumId = 'ai_resume_premium';
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // Callback for purchase updates
  final void Function(bool isPremium)? onPurchaseUpdated;
  
  PurchaseService({this.onPurchaseUpdated}) {
    _initializeIAP();
  }
  
  void _initializeIAP() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        debugPrint('IAP Stream error: $error');
      },
    );
  }
  
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show loading UI
        debugPrint('Purchase pending');
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Show error UI
        debugPrint('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        // Grant entitlement for the purchased product
        if (purchaseDetails.productID == premiumId) {
          await _savePremiumStatus(true);
          onPurchaseUpdated?.call(true);
        }
      }
      
      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }
  
  Future<bool> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool('is_premium', isPremium);
  }
  
  Future<bool> buyPremium() async {
    try {
      final available = await _iap.isAvailable();
      if (!available) {
        debugPrint('IAP not available');
        return false;
      }
      
      // Query product details
      final ProductDetailsResponse response = 
          await _iap.queryProductDetails({premiumId});
          
      if (response.error != null) {
        debugPrint('Error querying IAP products: ${response.error}');
        return false;
      }
      
      if (response.productDetails.isEmpty) {
        debugPrint('No products found');
        return false;
      }
      
      // Get the product
      final ProductDetails productDetails = response.productDetails.first;
      
      // Make the purchase
      final PurchaseParam purchaseParam = 
          PurchaseParam(productDetails: productDetails);
          
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Error during purchase: $e');
      return false;
    }
  }
  
  Future<bool> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
  
  void dispose() {
    _subscription?.cancel();
  }
}
