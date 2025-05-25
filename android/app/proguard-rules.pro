# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# In-App Purchase
-keep class com.android.billingclient.api.** { *; }

# Amazon IAP
-keep class com.amazon.device.iap.** { *; }
-dontwarn com.amazon.device.iap.**

# PDF generation
-keep class com.itextpdf.** { *; }
-dontwarn com.itextpdf.**

# Secure Storage
-keep class androidx.security.crypto.** { *; }

# SQLite
-keep class io.flutter.plugins.sqflite.** { *; }

# HTTP
-keep class io.flutter.plugins.connectivity.** { *; }

# General optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
