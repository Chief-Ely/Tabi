# ========== PLAY CORE ESSENTIALS ==========
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.common.** { *; }

# ========== FLUTTER DEFERRED COMPONENTS ==========
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# ========== REFLECTION CLASSES ==========
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# ========== DYNAMIC FEATURE INSTALLATION ==========
-keep class com.google.android.play.core.splitinstall.** {
    *;
}
-keep class com.google.android.play.core.splitinstall.model.** {
    *;
}

# ========== ADDITIONAL ML KIT PROTECTION ==========
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# ========== KOTLIN COROUTINES SUPPORT ==========
-keep class kotlinx.coroutines.** { *; }
-keep class kotlin.coroutines.** { *; }

# ========== FLUTTER ENGINE ==========
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.plugin.** { *; }

# ========== FIREBASE/GMS ==========
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.common.annotation.NoNullnessRewrite
-keep class com.google.android.gms.tasks.** { *; }

# ========== ANNOTATIONS ==========
-keepattributes *Annotation*
-keep class * implements java.lang.annotation.Annotation { *; }