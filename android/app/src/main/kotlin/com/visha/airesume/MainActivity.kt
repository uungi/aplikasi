package com.visha.airesume

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.Manifest
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.visha.airesume/platform"
    private val PERMISSIONS_REQUEST_CODE = 1001
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPlatformVersion" -> {
                    result.success("Android ${Build.VERSION.RELEASE}")
                }
                "checkPermissions" -> {
                    val permissionsToCheck = call.argument<List<String>>("permissions") ?: listOf()
                    result.success(checkPermissions(permissionsToCheck))
                }
                "requestPermissions" -> {
                    val permissionsToRequest = call.argument<List<String>>("permissions") ?: listOf()
                    requestPermissions(permissionsToRequest)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun checkPermissions(permissions: List<String>): Map<String, Boolean> {
        val result = mutableMapOf<String, Boolean>()
        
        for (permission in permissions) {
            result[permission] = ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        }
        
        return result
    }
    
    private fun requestPermissions(permissions: List<String>) {
        val permissionsToRequest = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }.toTypedArray()
        
        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsToRequest, PERMISSIONS_REQUEST_CODE)
        }
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == PERMISSIONS_REQUEST_CODE) {
            val channel = flutterEngine?.dartExecutor?.binaryMessenger?.let {
                MethodChannel(it, CHANNEL)
            }
            
            val result = mutableMapOf<String, Boolean>()
            for (i in permissions.indices) {
                result[permissions[i]] = grantResults[i] == PackageManager.PERMISSION_GRANTED
            }
            
            channel?.invokeMethod("permissionsResult", result)
        }
    }
}
