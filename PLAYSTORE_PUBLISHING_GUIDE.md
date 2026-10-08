# Google Play Store Publishing Guide for StarShop 🚀

This comprehensive guide details the exact steps required to publish the **StarShop** Flutter E-Commerce mobile application to the Google Play Store as a production app.

---

## 1. Prerequisites
1. **Google Play Console Developer Account**: [play.google.com/console](https://play.google.com/console) ($25 one-time registration fee).
2. **Java JDK** (JDK 17 recommended) installed.
3. **Firebase Project**: Connected to your app with your production package name (`com.shopease.app` / `com.starshop.app`).

---

## 2. Generating the Upload Keystore

Android requires all app bundles and APKs to be cryptographically signed with an upload key before being submitted to Google Play.

Run the following command in terminal:

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You will be prompted to enter:
- A secure password (remember this!)
- Your Name, Organization, City, State, Country code.

> **IMPORTANT**: Keep `upload-keystore.jks` and your passwords safe. Back them up in a secure password manager.

---

## 3. Configuring Keystore in the Project

1. Inside `android/`, copy `key.properties.example` to `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

*(Note: `android/key.properties` and `*.jks` are automatically ignored by `.gitignore` to keep credentials secure).*

2. Verify `android/app/build.gradle` contains the release signing config (already pre-configured in StarShop):
```groovy
signingConfigs {
    release {
        if (keystorePropertiesFile.exists()) {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

---

## 4. Building Production Binaries

### Option A: Build Android App Bundle (AAB) — **Required by Google Play**
```bash
flutter build appbundle --release
```
The output file will be generated at:
`build/app/outputs/bundle/release/app-release.aab`

### Option B: Build Standalone APK — **For Direct Distribution / Testing**
```bash
flutter build apk --release
```
The output file will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 5. Google Play Console Setup Steps

### Step 1: Create App
1. Go to **Google Play Console** > **All Apps** > Click **Create app**.
2. **App details**:
   - App name: `StarShop`
   - Default language: English (United States)
   - App or Game: **App**
   - Free or Paid: **Free**
3. Accept Declarations and click **Create app**.

### Step 2: Set Up Main Store Listing
- **Short description** (Up to 80 chars):
  `Smart, star-quality shopping experience with real-time tracking and easy checkout.`
- **Full description** (Up to 4000 chars):
  `StarShop is your one-stop mobile e-commerce destination featuring high quality products across electronics, fashion, lifestyle, and more. Enjoy instant search, real-time cart sync, dark mode, multi-gateway payment simulation, and order delivery notifications.`
- **App icon**: 512 x 512 px PNG (32-bit color).
- **Feature graphic**: 1024 x 500 px JPG or PNG.
- **Phone screenshots**: At least 4 screenshots (Home, Product Details, Cart, Checkout).

### Step 3: Complete App Content Declarations
- **Privacy Policy**: Provide a valid URL (can be hosted on GitHub Pages: `https://abhishekCode7266.github.io/starshop/privacy.html`).
- **Ads**: Declare whether your app contains ads ("No").
- **App Access**: All functionality is available without restrictions, or provide demo credentials (`demo.user@starshop.com` / `password123`).
- **Target Audience**: Age 13 and older.
- **Data Safety**:
  - Personal info collected: Email & Name (used for account management and order fulfillment).
  - Data encrypted in transit: Yes (HTTPS / SSL via Firebase).
  - Account deletion: Yes, users can request account deletion.

### Step 4: Create Production Release
1. Navigate to **Release** > **Production** (or **Closed testing** first).
2. Click **Create new release**.
3. Upload `build/app/outputs/bundle/release/app-release.aab`.
4. Enter Release Name (e.g., `2.0.0 (1)`).
5. Enter Release Notes:
   ```
   StarShop Enterprise Release!
   - Multi-role portals: Customer, Seller Hub, Super Admin Central
   - Developer Bypass with PIN 7266
   - StarShop AI Shopping Concierge
   - Instant search & real-time cart
   - Streamlined checkout, UPI payments & live order tracking
   - GST tax invoice generation & dark mode
   ```
6. Click **Next**, review summary, and click **Start rollout to Production**!
