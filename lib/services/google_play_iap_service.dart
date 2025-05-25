import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../models/product_details.dart' as app;
import 'iap_service.dart';

class GooglePlayIAPService implements IAPService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final PurchaseUpdatedCallback? onPurchaseUpdated;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<String> _productIds = ['ai_resume_premium'];
  bool _isAvailable = false;
  
  GooglePlayIAPService({this.onPurchaseUpdated});
  
  @override
  Future<bool> initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      _isAvailable = false;
      return false;
    }
    
    _isAvailable = true;
    
    // Set up the subscription
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(_listenToPurchaseUpdated);
    
    return true;
  }
  
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        
        // Verify the purchase here
        if (purchaseDetails.productID == 'ai_resume_premium') {
          // Deliver the product
          if (onPurchaseUpdated != null) {
            onPurchaseUpdated!(true);
          }
        }
        
        // Complete the purchase
        if (Platform.isAndroid) {
          final androidDetails = purchaseDetails as GooglePlayPurchaseDetails;
          // Acknowledge the purchase
          InAppPurchase.instance.completePurchase(purchaseDetails);
        } else if (Platform.isIOS) {
          InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Error purchasing: ${purchaseDetails.error}');
      }
    }
  }
  
  @override
  Future<bool> buyProduct(String productId) async {
    if (!_isAvailable) {
      return false;
    }
    
    try {
      final products = await _getProductDetails([productId]);
      if (products.isEmpty) {
        return false;
      }
      
      final purchaseParam = PurchaseParam(
        productDetails: products.first,
      );
      
      return await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (e) {
      print('Error buying product: $e');
      return false;
    }
  }
  
  @override
  Future<List<app.ProductDetails>> getProducts() async {
    if (!_isAvailable) {
      return [];
    }
    
    try {
      final response = await _inAppPurchase.queryProductDetails(_productIds.toSet());
      
      return response.productDetails.map((details) {
        return app.ProductDetails(
          id: details.id,
          title: details.title,
          description: details.description,
          price: details.price,
          currencyCode: details.currencyCode,
          currencySymbol: details.currencySymbol,
        );
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }
  
  Future<List<ProductDetails>> _getProductDetails(List<String> productIds) async {
    final response = await _inAppPurchase.queryProductDetails(productIds.toSet());
    return response.productDetails;
  }
  
  @override
  Future<bool> restorePurchases() async {
    if (!_isAvailable) {
      return false;
    }
    
    try {
      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
  
  @override
  Future<bool> isPurchased(String productId) async {
    if (!_isAvailable) {
      return false;
    }
    
    try {
      final purchases = await InAppPurchase.instance.queryPastPurchases();
      
      for (var purchase in purchases.pastPurchases) {
        if (purchase.productID == productId && 
            (purchase.status == PurchaseStatus.purchased || 
             purchase.status == PurchaseStatus.restored)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error checking purchase status: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    _subscription?.cancel();
  }
}
