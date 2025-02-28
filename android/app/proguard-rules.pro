# Keep Google Places API classes
-keep class com.google.android.libraries.places.** { *; }

# Keep Stripe SDK classes
-keep class com.stripe.** { *; }

# Keep Stripe Card Scan classes
-keep class com.stripe.android.stripecardscan.** { *; }

# Keep BouncyCastle security provider classes
-keep class org.bouncycastle.** { *; }

# Keep javax.naming classes
-dontwarn javax.naming.**
-keep class javax.naming.** { *; }

# Keep necessary Kotlin metadata
-keepattributes InnerClasses, EnclosingMethod, Signature, Exceptions, Deprecated, SourceFile, LineNumberTable, *Annotation*

# Keep classes required for reflection
-keep class kotlin.Metadata { *; }
-keep class kotlin.jvm.internal.** { *; }

# Keep classes used by coroutines
-keep class kotlinx.coroutines.** { *; }

# Don't remove dynamically loaded classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
