# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# GetX rules
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * extends androidx.lifecycle.AndroidViewModel { *; }
-keep class * implements androidx.lifecycle.ViewModelProvider.Factory { *; }
-keep class * extends getx.GetxService { *; }
-keep class * extends getx.GetxController { *; }
-keep class * extends getx.GetView { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Shared Preferences
-keep class android.content.SharedPreferences { *; }

# Dio rules
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class io.reactivex.** { *; }

# Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes
-keep class com.example.slims.** { *; }
-keep class slims.** { *; }

# Prevent R8 from removing SecureStorageHelper methods
-keep class slims.core.utils.SecureStorageHelper { *; }
-keep class slims.core.utils.SharedPrefsHelper { *; }

# Prevent R8 from removing navigation related classes
-keep class slims.infrastructure.navigation.** { *; }

# Keep all GetX bindings
-keep class * extends getx.Bindings { *; }

# Keep all screen classes
-keep class * extends getx.GetView { *; }
-keep class * extends StatelessWidget { *; }
-keep class * extends StatefulWidget { *; }

# Custom button widget
-keep class slims.presentation.widgets.buttons.CustomButton { *; }

# Google Play Core Split Install - FIX FOR MISSING CLASSES
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Flutter Play Store Split Application
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }

# Prevent obfuscation of method names that are called via reflection
-keepclassmembernames class * {
    @androidx.annotation.Keep <methods>;
}

-keep @androidx.annotation.Keep class * {*;}
