# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Amazon IAP SDK
-keep class com.amazon.** {*;}
-keep interface com.amazon.** {*;}
-keepattributes *Annotation*

# In App Purchase
-keep class com.android.vending.billing.**
-keep class com.android.billingclient.** { *; }

# Mengizinkan serialization untuk models
-keepclassmembers class com.yourcompany.ai_resume_generator.models.** {
    <fields>;
}
