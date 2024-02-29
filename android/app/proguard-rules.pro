# Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Gson
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-dontwarn com.google.android.gms.auth.api.signin.**
-keep class com.google.android.gms.auth.api.** {*;}
-keep class com.google.android.gms.common.api.** {*;}
-keep class com.google.android.gms.common.images.** {*;}
-keep class com.google.googlesignin.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Play Services Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Google Analytics
-keep class com.google.android.gms.analytics.** { *; }
-dontwarn com.google.android.gms.analytics.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.maps.**

# Support Library
-keep class android.support.v4.** { *; }
-dontwarn android.support.v4.**

# Your App Package
-keep class com.sanggong.toyou.** { *; }
-dontwarn com.sanggong.toyou.**

# Apple Sign In
-keep class com.apple.** { *; }
-keep class org.apache.http.** { *; }
-keep class com.google.gson.** { *; }
-keep class com.aboutyou.dart_packages.sign_in_with_apple.** { *; }

# Add any other ProGuard rules you need for your app.