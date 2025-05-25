import '../models/product_details.dart';

typedef PurchaseUpdatedCallback = void Function(bool isPremium);

abstract class IAPService {
  Future<bool> initialize();
  Future<bool> buyProduct(String productId);
  Future<List<ProductDetails>> getProducts();
  Future<bool> restorePurchases();
  Future<bool> isPurchased(String productId);
  void dispose();
}
