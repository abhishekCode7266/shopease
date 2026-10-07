# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase Rules
-dontwarn com.google.firebase.**
-keep class com.google.firebase.** { *; }

# Cloud Firestore
-keep class com.google.firebase.firestore.** { *; }

# Core desugaring
-keep class j$.** { *; }
