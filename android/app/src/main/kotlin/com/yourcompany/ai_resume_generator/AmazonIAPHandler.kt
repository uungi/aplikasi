package com.yourcompany.ai_resume_generator

import android.app.Activity
import android.util.Log
import com.amazon.device.iap.PurchasingListener
import com.amazon.device.iap.PurchasingService
import com.amazon.device.iap.model.*
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class AmazonIAPHandler(private val activity: Activity) : PurchasingListener {
    private var methodChannel: MethodChannel? = null
    private val TAG = "AmazonIAPHandler"
    
    fun initialize(channel: MethodChannel): Boolean {
        try {
            methodChannel = channel
            PurchasingService.registerListener(activity.applicationContext, this)
            Log.d(TAG, "Amazon IAP initialized")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing Amazon IAP: ${e.message}")
            return false
        }
    }
    
    fun getProducts(productIds: List<String>): Boolean {
        try {
            val productSkus = HashSet<String>(productIds)
            PurchasingService.getProductData(productSkus)
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error getting products: ${e.message}")
            return false
        }
    }
    
    fun buyProduct(productId: String): Boolean {
        try {
            val requestId = PurchasingService.purchase(productId)
            Log.d(TAG, "Purchase initiated with requestId: $requestId")
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error buying product: ${e.message}")
            return false
        }
    }
    
    fun restorePurchases(): Boolean {
        try {
            PurchasingService.getPurchaseUpdates(true)
            return true
        } catch (e: Exception) {
            Log.e(TAG, "Error restoring purchases: ${e.message}")
            return false
        }
    }
    
    override fun onProductDataResponse(response: ProductDataResponse) {
        val status = response.requestStatus
        val requestId = response.requestId
        
        Log.d(TAG, "onProductDataResponse: $status for request $requestId")
        
        when (status) {
            ProductDataResponse.RequestStatus.SUCCESSFUL -> {
                val products = response.productData
                val jsonArray = JSONArray()
                
                for (sku in products.keys) {
                    val product = products[sku]
                    val jsonProduct = JSONObject()
                    jsonProduct.put("id", product?.sku)
                    jsonProduct.put("title", product?.title)
                    jsonProduct.put("description", product?.description)
                    jsonProduct.put("price", product?.price)
                    jsonProduct.put("currencyCode", "USD") // Amazon doesn't provide currency code
                    jsonProduct.put("currencySymbol", "$") // Amazon doesn't provide currency symbol
                    
                    jsonArray.put(jsonProduct)
                }
                
                activity.runOnUiThread {
                    methodChannel?.invokeMethod("onProductsReceived", jsonArray.toString())
                }
            }
            ProductDataResponse.RequestStatus.FAILED -> {
                activity.runOnUiThread {
                    methodChannel?.invokeMethod("onProductsError", "Failed to get products")
                }
            }
            else -> {
                activity.runOnUiThread {
                    methodChannel?.invokeMethod("onProductsError", "Unknown error getting products")
                }
            }
        }
    }
    
    override fun onPurchaseResponse(response: PurchaseResponse) {
        val status = response.requestStatus
        val requestId = response.requestId
        
        Log.d(TAG, "onPurchaseResponse: $status for request $requestId")
        
        when (status) {
            PurchaseResponse.RequestStatus.SUCCESSFUL -> {
                val receipt = response.receipt
                val isPremium = receipt.sku == "ai_resume_premium"
                
                activity.runOnUiThread {
                    val args = HashMap<String, Any>()
                    args["isPremium"] = isPremium
                    methodChannel?.invokeMethod("onPurchaseUpdated", args)
                }
            }
            PurchaseResponse.RequestStatus.ALREADY_PURCHASED -> {
                activity.runOnUiThread {
                    val args = HashMap<String, Any>()
                    args["isPremium"] = true
                    methodChannel?.invokeMethod("onPurchaseUpdated", args)
                }
            }
            else -> {
                activity.runOnUiThread {
                    methodChannel?.invokeMethod("onPurchaseError", "Purchase failed with status: $status")
                }
            }
        }
    }
    
    override fun onPurchaseUpdatesResponse(response: PurchaseUpdatesResponse) {
        val status = response.requestStatus
        val requestId = response.requestId
        
        Log.d(TAG, "onPurchaseUpdatesResponse: $status for request $requestId")
        
        when (status) {
            PurchaseUpdatesResponse.RequestStatus.SUCCESSFUL -> {
                val receipts = response.receipts
                var isPremium = false
                
                for (receipt in receipts) {
                    if (receipt.sku == "ai_resume_premium" && 
                        receipt.productType == ProductType.ENTITLED) {
                        isPremium = true
                        break
                    }
                }
                
                activity.runOnUiThread {
                    val args = HashMap<String, Any>()
                    args["isPremium"] = isPremium
                    methodChannel?.invokeMethod("onPurchaseUpdated", args)
                }
            }
            else -> {
                activity.runOnUiThread {
                    methodChannel?.invokeMethod("onRestoreError", "Restore failed with status: $status")
                }
            }
        }
    }
    
    override fun onUserDataResponse(response: UserDataResponse) {
        // Not used for this implementation
    }
}
