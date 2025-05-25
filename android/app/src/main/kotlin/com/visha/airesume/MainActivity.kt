package com.visha.airesume

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.visha.airesume/amazon_iap"
    private lateinit var amazonIAPHandler: AmazonIAPHandler
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        amazonIAPHandler = AmazonIAPHandler(this)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val success = amazonIAPHandler.initialize(MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL))
                    result.success(success)
                }
                "getProducts" -> {
                    val productIds = call.argument<List<String>>("productIds") ?: listOf()
                    val success = amazonIAPHandler.getProducts(productIds)
                    result.success(success)
                }
                "buyProduct" -> {
                    val productId = call.argument<String>("productId") ?: ""
                    val success = amazonIAPHandler.buyProduct(productId)
                    result.success(success)
                }
                "restorePurchases" -> {
                    val success = amazonIAPHandler.restorePurchases()
                    result.success(success)
                }
                "isPurchased" -> {
                    // This would need to be implemented with a local cache
                    // For now, we'll just return false
                    result.success(false)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Log the installer package for debugging
        try {
            val packageName = packageName
            val installer = packageManager.getInstallerPackageName(packageName)
            Log.d("MainActivity", "Installer package: $installer")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error getting installer package: ${e.message}")
        }
    }
}
