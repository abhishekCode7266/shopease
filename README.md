# ShopEase 🛍️ - Production-Ready Flutter E-Commerce App

ShopEase is a full-featured, production-ready mobile e-commerce application built with Flutter (Dart 3+), Material 3, and Firebase backend (Authentication, Cloud Firestore, and Firebase Cloud Messaging). The app is architected for Android deployment and Google Play Store submission.

---

## 🌟 Key Features

1. **Firebase Authentication**
   - Email/password signup, login, session persistence, and password reset.
   - Robust form validation (valid email pattern, min 6 char password, matching passwords).
   - User-friendly error message translation for all Firebase Auth exceptions.
   - Quick Demo Credential auto-fill button.

2. **Real-Time Product Catalog**
   - Streamed directly from Cloud Firestore (`products` collection).
   - Instant search across title, category, and descriptions.
   - Horizontal category filter chips (Electronics, Fashion, Home & Living, Books, Beauty, Sports).
   - Product Cards featuring rating stars, reviews count, price, and instant Add-to-Cart button.
   - 12 pre-seeded sample products with high-resolution imagery and realistic specifications.

3. **Persistent Shopping Cart**
   - Firestore synchronisation under `users/{uid}/cart/{productId}` so cart state persists across app re-installs and sessions.
   - Quantity stepper (+ / -), automatic removal when quantity is 0.
   - Live real-time subtotal, 8% tax calculation, and free shipping logic (orders over $50).
   - Empty cart state with "Continue Shopping" CTA.

4. **Order Placement & History Tracking**
   - Delivery address form with validation (Name, Phone, Street, City, State, PIN).
   - Saves to `users/{uid}/orders/{orderId}` with complete item snapshot, delivery address, payment mode, and timestamp.
   - Visual order tracking stepper: **Placed** ➡️ **Shipped** ➡️ **Delivered**.
   - Cart automatically clears upon successful checkout.

5. **Mock Payment Gateway**
   - Multi-option payment screen: Cash on Delivery, Simulated Credit/Debit Card, Simulated UPI.
   - 2-second realistic processing loader dialog.
   - Success screen with Order ID and itemized breakdown.

6. **Theming & Preferences**
   - Material 3 Light & Dark mode toggle.
   - Persisted locally with `SharedPreferences`.

7. **Push Notifications (FCM)**
   - Firebase Cloud Messaging integration + Android Notification Channel setup.
   - Automated native push notification triggered upon successful order placement.

---

## 📁 Project Architecture

```
lib/
├── main.dart                  # App entry point, MultiProvider & Theme injection
├── firebase_options.dart      # FlutterFire platform configuration
├── models/
│   ├── product_model.dart     # Firestore Product entity
│   ├── cart_item_model.dart   # Cart Item entity & price computation
│   ├── order_model.dart       # Order entity & Shipping Address
│   └── user_model.dart        # User profile entity
├── services/
│   ├── auth_service.dart      # Firebase Auth wrapper & error handling
│   ├── product_service.dart   # Firestore products stream & seeding
│   ├── cart_service.dart      # Firestore user cart synchronization
│   ├── order_service.dart     # Firestore orders management
│   └── notification_service.dart # FCM & local notification triggers
├── providers/
│   ├── auth_provider.dart     # Reactive auth state & profile
│   ├── product_provider.dart  # Filtered product streams & category filters
│   ├── cart_provider.dart     # Live cart calculation & operations
│   ├── order_provider.dart    # Order placement & orders history
│   └── theme_provider.dart    # Light/Dark mode state with SharedPreferences
├── screens/
│   ├── splash_screen.dart     # Animated branded splash with session router
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart   # Product feed, search, and category chips
│   ├── product/
│   │   └── product_detail_screen.dart # Image hero, quantity picker, reviews
│   ├── cart/
│   │   └── cart_screen.dart   # Cart list & live price breakdown
│   ├── checkout/
│   │   ├── checkout_screen.dart # Address form
│   │   ├── payment_screen.dart  # Mock payment selector
│   │   └── order_success_screen.dart # Order confirmation
│   ├── orders/
│   │   ├── orders_screen.dart # Order history stream
│   │   └── order_detail_screen.dart # Tracking timeline & invoice
│   └── profile/
│       ├── profile_screen.dart # Account details & settings
│       └── edit_profile_screen.dart # Edit user name
├── widgets/
│   ├── custom_button.dart     # Accessible button with loading spinner
│   ├── custom_text_field.dart # Form text input with validation styling
│   ├── empty_state_view.dart  # Reusable empty screen state
│   ├── loading_view.dart      # Loading indicator
│   ├── product_card.dart      # Grid product card with cached image
│   ├── cart_item_tile.dart    # Cart item with stepper
│   └── order_card.dart        # Order summary card with status badge
└── utils/
    ├── app_theme.dart         # Material 3 light and dark theme definitions
    ├── constants.dart         # Global constants, icons, colors
    ├── sample_data.dart       # 12 pre-seeded sample products
    └── validators.dart        # Robust form field validators
```

---

## 🔒 Cloud Firestore Security Rules

Deploy the included `firestore.rules`:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /products/{productId} {
      allow read: if true;
      allow write: if isAuthenticated();
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);
      match /cart/{cartItemId} {
        allow read, write: if isOwner(userId);
      }
      match /orders/{orderId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

## 🚀 Step-by-Step Setup & Build Instructions

### 1. Create Firebase Project
1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and name it `shopease-app`.
3. Enable **Email/Password** under **Authentication > Sign-in method**.
4. Create a **Cloud Firestore** database (select Production Mode).
5. In Firebase Project Settings, add an Android app with package name:
   `com.shopease.app`
6. Download the generated `google-services.json` and place it at:
   `android/app/google-services.json`

### 2. Configure Firebase with FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=shopease-app
```

### 3. Run and Test Locally
```bash
# Get dependencies
flutter pub get

# Run unit and widget tests
flutter test

# Run app on connected Android device or emulator
flutter run
```

### 4. Build Standalone Release APK
```bash
flutter build apk --release
```
Your release APK is generated at:
`build/app/outputs/flutter-apk/app-release.apk`

### 5. Build Google Play Store App Bundle (AAB)
```bash
flutter build appbundle --release
```
Your production Play Store bundle is generated at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 🎬 Demo Video Script

| Scene | Duration | Visual Action | Voiceover / Text |
|---|---|---|---|
| **1. Splash & Auth** | 0:00 - 0:10 | App opens with smooth branded splash screen. Navigate to Login. Click "Fill Demo Credentials" and tap "Sign In". | *"Welcome to ShopEase! Users can authenticate securely with email/password or test instantly with demo credentials."* |
| **2. Product Catalog** | 0:10 - 0:25 | Home feed shows products with images, ratings, and prices. Tap "Electronics" chip to filter, then search for "Headphones". | *"Browse an extensive Firestore catalog. Filter by category or search instantly with real-time Firestore updates."* |
| **3. Product Detail & Cart** | 0:25 - 0:40 | Tap "Wireless Headphones". View specs, change quantity to 2, and tap "Add to Cart". Open Cart tab. | *"Seamless product details with hero animations. Adjust quantity and watch live subtotal, tax, and free shipping compute automatically."* |
| **4. Checkout** | 0:40 - 0:55 | Tap "Proceed to Checkout". Tap "Auto-Fill" for recipient address. Review order summary and tap "Continue to Payment". | *"Streamlined checkout with comprehensive address validation and instant invoice summary."* |
| **5. Mock Payment & Success** | 0:55 - 1:10 | Select "Credit / Debit Card" or "UPI". Tap "Pay & Place Order". 2-second security loader runs. Success checkmark appears with FCM push notification. | *"Choose between Cash on Delivery, Card, or UPI with simulated instant verification and automated push notification."* |
| **6. Orders & Dark Mode** | 1:10 - 1:25 | Open "Orders" tab to track order progress (Placed -> Shipped -> Delivered). Switch to Profile and toggle Dark Mode. | *"Track every order with real-time status timelines, and toggle sleek Material 3 Dark Mode anytime."* |

---

## 📄 License
MIT License. © 2026 ShopEase.
