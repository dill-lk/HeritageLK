-keep class app_lib.** { *; }
-keep class lk.heritagelk.mobile.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-dontwarn android.webkit.**
-dontwarn javax.crypto.**
-dontwarn javax.net.ssl.**
