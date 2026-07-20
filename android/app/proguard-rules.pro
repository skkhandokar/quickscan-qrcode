# Flutter standard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep MainActivity and AndroidX classes
-keep class androidx.core.app.CoreComponentFactory { *; }
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.br.BroadcastReceiver

# Keep Camera and Scanner plugins
-keep class dev.zxing.** { *; }
-keep class com.google.zxing.** { *; }