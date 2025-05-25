import 'dart:async';
import 'package:flutter/services.dart';
import '../models/product_details.dart' as app;
import 'iap_service.dart';

class AmazonIAPService implements IAPService {
  static const MethodChannel _channel = MethodChannel('com.visha.airesume/amazon_iap');
  final PurchaseUpdatedCallback? onPurchaseUpdated;
  bool _isInitialized = false;
  
  AmazonIAPService({this.onPurchaseUpdated});
  
  @override
  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod('initialize');
      _isInitialized = result ?? false;
      
      if (_isInitialized) {
        // Set up listener for purchase updates
        _channel.setMethodCallHandler(_handleMethodCall);
      }
      
      return _isInitialized;
    } catch (e) {
      print('Error initializing Amazon IAP: $e');
      return false;
    }
  }
  
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPurchaseUpdated':
        final Map<String, dynamic> args = Map<String, dynamic>.from(call.arguments);
        final bool isPremium = args['isPremium'] ?? false;
        
        if (onPurchaseUpdated != null) {
          onPurchaseUpdated!(isPremium);
        }
        break;
      default:
        print('Unknown method ${call.method}');
    }
  }
  
  @override
  Future<bool> buyProduct(String productId) async {
    if (!_isInitialized) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('buyProduct', {
        'productId': productId,
      });
      
      return result ?? false;
    } catch (e) {
      print('Error buying product: $e');
      return false;
    }
  }
  
  @override
  Future<List<app.ProductDetails>> getProducts() async {
    if (!_isInitialized) {
      return [];
    }
    
    try {
      final List<dynamic> result = await _channel.invokeMethod('getProducts', {
        'productIds': ['ai_resume_premium'],
      });
      
      return result.map((item) {
        final Map<String, dynamic> product = Map<String, dynamic>.from(item);
        
        return app.ProductDetails(
          id: product['id'],
          title: product['title'],
          description: product['description'],
          price: product['price'],
          currencyCode: product['currencyCode'],
          currencySymbol: product['currencySymbol'],
        );
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }
  
  @override
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('restorePurchases');
      return result ?? false;
    } catch (e) {
      print('Error restoring purchases: $e');
      return false;
    }
  }
  
  @override
  Future<bool> isPurchased(String productId) async {
    if (!_isInitialized) {
      return false;
    }
    
    try {
      final result = await _channel.invokeMethod('isPurchased', {
        'productId': productId,
      });
      
      return result ?? false;
    } catch (e) {
      print('Error checking purchase status: $e');
      return false;
    }
  }
  
  @override
  void dispose() {
    // Nothing to dispose for Amazon IAP
  }
}
