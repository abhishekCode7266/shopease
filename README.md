# ShopEase 🛍️ - Enterprise Multi-Role Flutter E-Commerce Platform

[![ShopEase CI/CD](https://github.com/abhishekCode7266/shopease/actions/workflows/deploy.yml/badge.svg)](https://github.com/abhishekCode7266/shopease/actions/workflows/deploy.yml)
[![Live Web Preview](https://img.shields.io/badge/Web_Preview-Live_on_GitHub_Pages-blue?style=flat&logo=googlechrome)](https://abhishekCode7266.github.io/shopease/)
[![Release v2.0.0](https://img.shields.io/badge/Release-v2.0.0_Enterprise-green?style=flat&logo=android)](https://github.com/abhishekCode7266/shopease/releases/tag/v2.0.0)
[![RSS Feed](https://img.shields.io/badge/RSS_Feed-Updates-orange?style=flat&logo=rss)](https://abhishekCode7266.github.io/shopease/feed.xml)

**ShopEase** is a comprehensive, production-ready, enterprise-grade mobile and web E-Commerce application built with **Flutter (Dart 3+)**, **Material 3**, and **Firebase** (Auth, Cloud Firestore, Cloud Messaging). Designed from the ground up for high reliability, responsiveness, and multi-role operations across **Customer**, **Seller**, and **Super Admin** workflows.

---

## 🚀 Live Links & Downloads

| Resource | URL |
| :--- | :--- |
| **Live Web App (GitHub Pages)** | [https://abhishekCode7266.github.io/shopease/](https://abhishekCode7266.github.io/shopease/) |
| **Android Release APK Download** | [Download `app-release.apk`](https://github.com/abhishekCode7266/shopease/releases/download/v2.0.0/app-release.apk) |
| **Google Play Store App Bundle (AAB)** | [Download `app-release.aab`](https://github.com/abhishekCode7266/shopease/releases/download/v2.0.0/app-release.aab) |
| **App Updates RSS Feed** | [https://abhishekCode7266.github.io/shopease/feed.xml](https://abhishekCode7266.github.io/shopease/feed.xml) |
| **GitHub Source Code Repository** | [https://github.com/abhishekCode7266/shopease](https://github.com/abhishekCode7266/shopease) |

---

## 🔐 Developer Mode Bypass (डेवलपर मोड बाईपास)

For rapid inspection, testing, and debugging without needing active Firebase email credentials or SMS verification:

1. Look for the circular **Developer Settings Icon (⚡/⚙️)** in the top-right corner of the **Login**, **Splash**, or **Home** screen.
2. Enter the secret Developer PIN: **`7266`** (or `1234`).
3. Select your desired entry role:
   - 🛡️ **Super Admin**: Instant access to Platform Analytics, Monthly Revenue Charts, Merchant Verification Queue, User Moderation, and Broadcast Alerts.
   - 🏪 **Seller Hub**: Direct access to Merchant Inventory, Add/Edit Products, Order Dispatch, and Settlement Ledgers.
   - 🛍️ **Customer**: Full shopping flow with pre-seeded cart items, Wishlist, Saved Addresses, and Order History.
4. Tap **"Bypass & Enter Now (बाईपास करें)"** to unlock all screens and permissions instantly.

---

## 🌟 Comprehensive Architecture & Sections

### 1. Customer Shopping Experience
- **Dynamic Homepage**: High-impact promotional banners, vector branding (`ShopEaseLogo`), and category chips.
- **Search & Filters**: Real-time multi-attribute search with bottom sheet controls for Price Range slider, Minimum Star Rating, In-Stock filter, and Sort criteria (Popularity, Price Low-High, Price High-Low, Discount).
- **Product Details**: Multi-angle image hero, 4K video preview modal, technical specifications table, verified merchant info, and customer reviews with star ratings.
- **Side-by-Side Comparison**: Interactive product comparison table across specifications, price, and ratings.
- **Recently Viewed History**: Real-time horizontal browsing carousel.
- **Wishlist**: Dedicated wishlist grid with one-tap "Add All to Cart".

### 2. User Account & Multi-Address Management
- **Address Book**: Full CRUD support for multiple shipping addresses (Home, Work, Other) with 1-tap default address selection.
- **Notification Center**: Filtered inbox (All, Orders, Promos, System Alerts) with unread counters and swipe-to-dismiss.
- **Session Persistence**: Automatic login persistence across app restarts.

### 3. Cart & Smart Checkout
- **Cart Management**: Live quantity controls, automatic empty state CTA, and Firestore cloud synchronization.
- **Tax Breakdown**: Compliant **18% GST (9% CGST + 9% SGST)** calculation on discounted subtotal.
- **Coupons & Promo Codes**: Built-in coupon engine supporting:
  - `WELCOME50` - Flat 50% discount (up to ₹50)
  - `EASE20` - 20% discount on orders above ₹999
  - `FREESHIP` - 100% Free Shipping waiver
  - `FESTIVE10` - 10% seasonal cashback
- **Delivery Threshold**: Real-time progress bar towards Free Delivery (threshold: ₹50).

### 4. Indian & Global Payment Suite
- **UPI Transfer**: Instant transfer simulator for **PhonePe**, **Google Pay**, **Paytm**, and custom VPA (`user@upi`).
- **Credit & Debit Cards**: Cardholder name, 16-digit card validation, MM/YY expiry, CVV verification.
- **Net Banking**: Instant integration with India's top banks (HDFC, SBI, ICICI, Axis, Kotak, PNB).
- **Cash on Delivery (COD)**: Doorstep cash payment with QR code verification instructions.

### 5. Order Tracking & Compliance
- **Milestone Shipment Journey**: Live interactive step-by-step timeline:
  `Confirmed` ➡️ `Packed & Ready` ➡️ `Shipped (In Transit)` ➡️ `Out for Delivery` ➡️ `Delivered`.
- **Logistics Integration**: Carrier assignment (BlueDart, Delhivery, Ekart) with AWB tracking ID and ETA.
- **GSTIN Tax Invoices**: Formatted, printable computer-generated Tax Invoices with itemized description, SAC/HSN codes, and PDF download action.
- **Self-Service Actions**: Reason-based order cancellation and 7-day hassle-free return / refund workflow.

### 6. Seller Merchant Hub
- **Merchant Overview**: Net earnings calculation, pending order alerts, active catalog stats.
- **Inventory Manager**: Add new products, edit price/stock/MRP, upload image URLs, delete discontinued items.
- **Order Fulfillment**: Update order status (`Packed`, `Shipped`, `Delivered`) and manage customer returns.
- **Financial Settlements**: Gross volume, platform commission deduction (5%), GST collected, and spreadsheet ledger export (`.xlsx`).

### 7. Super Admin Central
- **Platform Analytics**: Gross merchandise volume (GMV), platform net revenue (20%), registered customers, and active sellers.
- **Visual Monthly Sales Chart**: Custom bar chart visualizing Jan–Dec revenue trajectories and peak performance months.
- **Category Share Breakdown**: Live percentage distribution across Electronics, Fashion, Home, and Books.
- **Merchant Verification Queue**: Review new seller applications (GSTIN, store profile) with Approve/Reject actions.
- **User Moderation**: Customer account oversight with live suspended/blocked toggle.
- **Platform Broadcasts**: Dispatch platform-wide notifications to all active users.

### 8. ShopEase AI Assistant Concierge
- **Conversational Shopping Assistant**: Built-in chat interface powered by Google DeepMind / Gemini logic.
- **Catalog Awareness**: Recommends products matching user budget and requirements with direct "View Product" cards.
- **Order Support**: Automatically fetches user's active orders and provides real-time tracking updates.

---

## 📁 Repository Directory Structure

```
shopease/
├── .github/workflows/
│   └── deploy.yml              # CI/CD: Automated Tests, APK, AAB & GitHub Pages
├── android/
│   ├── app/build.gradle.kts   # AGP 8.5.2, Java 17, Desugaring & Multidex
│   ├── build.gradle.kts       # Gradle 8.10.2 configuration
│   └── settings.gradle.kts    # Kotlin DSL plugins
├── lib/
│   ├── main.dart              # MultiProvider state orchestration
│   ├── firebase_options.dart  # Firebase platform options
│   ├── models/
│   │   ├── cart_item_model.dart
│   │   ├── coupon_model.dart
│   │   ├── notification_item_model.dart
│   │   ├── order_model.dart   # OrderTimeline, ShippingAddress, OrderItem
│   │   ├── product_model.dart # ProductReview, specs, videoUrl, sellerId
│   │   └── user_model.dart    # Roles: customer, seller, admin
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── cart_service.dart
│   │   ├── notification_service.dart
│   │   ├── order_service.dart
│   │   └── product_service.dart
│   ├── providers/
│   │   ├── admin_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── cart_provider.dart
│   │   ├── notification_provider.dart
│   │   ├── order_provider.dart
│   │   ├── product_provider.dart
│   │   └── theme_provider.dart
│   ├── screens/
│   │   ├── admin/
│   │   │   └── admin_dashboard_screen.dart
│   │   ├── ai/
│   │   │   └── ai_assistant_screen.dart
│   │   ├── auth/
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── cart/
│   │   │   └── cart_screen.dart
│   │   ├── checkout/
│   │   │   ├── checkout_screen.dart
│   │   │   ├── order_success_screen.dart
│   │   │   └── payment_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── notifications/
│   │   │   └── notification_center_screen.dart
│   │   ├── orders/
│   │   │   ├── invoice_screen.dart
│   │   │   ├── order_detail_screen.dart
│   │   │   ├── order_tracking_screen.dart
│   │   │   └── orders_screen.dart
│   │   ├── product/
│   │   │   ├── product_compare_screen.dart
│   │   │   └── product_detail_screen.dart
│   │   ├── profile/
│   │   │   ├── addresses_screen.dart
│   │   │   ├── edit_profile_screen.dart
│   │   │   └── profile_screen.dart
│   │   ├── seller/
│   │   │   └── seller_dashboard_screen.dart
│   │   ├── splash_screen.dart
│   │   └── wishlist/
│   │       └── wishlist_screen.dart
│   ├── widgets/
│   │   ├── cart_item_tile.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── developer_bypass_sheet.dart
│   │   ├── empty_state_view.dart
│   │   ├── loading_view.dart
│   │   ├── order_card.dart
│   │   ├── product_card.dart
│   │   └── shopease_logo.dart
│   └── utils/
│       ├── app_theme.dart
│       ├── constants.dart
│       ├── sample_data.dart
│       └── validators.dart
├── test/
│   ├── auth_provider_test.dart
│   ├── cart_calculation_test.dart
│   ├── validators_test.dart
│   └── widget_test.dart
├── firestore.rules
├── feed.xml
└── pubspec.yaml
```

---

## 🛠️ Build & Run Commands

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Test Suite & Lint
```bash
flutter analyze
flutter test
```

### 3. Run Locally (Chrome Web or Android)
```bash
# Run Web
flutter run -d chrome

# Run Android Device / Emulator
flutter run -d android
```

### 4. Build Release Artifacts
```bash
# Build Android Release APK
flutter build apk --release

# Build Google Play Store App Bundle (AAB)
flutter build appbundle --release

# Build Web (GitHub Pages release)
flutter build web --release --base-href "/shopease/"
```

---

## 🔒 Security & Firestore Rules

`firestore.rules` enforces strict data isolation:
- Products catalog: Publicly readable; writable by verified sellers and platform admins.
- Users collection: Users can only read and write their own documents (`request.auth.uid == userId`).
- Cart & Orders: Strict user-specific isolation with admin verification override.

---

## 📄 License & Credits
Crafted with ❤️ by **Abhishek Kumar** (`abhishekCode7266`). Built for modern, high-performance E-Commerce experiences on Android and Web.
