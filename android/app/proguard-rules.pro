# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter engine
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Hive - Local storage
-keep class * extends com.hive.** { *; }
-keep class * extends org.hive.** { *; }

# Gson - JSON parsing
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# QR Code and Barcode libraries
-keep class com.google.zxing.** { *; }
-keep class com.journeyapps.barcodescanner.** { *; }

# Mobile Scanner (Camera)
-keep class dev.steenbakker.mobile_scanner.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Google Play Core (for split APKs)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Common Flutter/Android optimizations
-keepclassmembers class * extends android.app.Activity {
    public void *(android.view.View);
}

-keepclassmembers class * extends android.app.Application {
    public <init>();
}

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Add project specific keep rules below

