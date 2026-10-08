import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred device orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase with fallback resilience
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Initialize Notification Service (FCM & Local notifications)
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification service notice: $e');
  }

  runApp(const StarShopApp());
}

class StarShopApp extends StatelessWidget {
  const StarShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (ctx) => CartProvider(
            initialUserId: ctx.read<AuthProvider>().user?.uid,
          ),
          update: (ctx, auth, cart) {
            final provider = cart ?? CartProvider();
            provider.updateUser(auth.user?.uid);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
          create: (ctx) => OrderProvider(
            initialUserId: ctx.read<AuthProvider>().user?.uid,
          ),
          update: (ctx, auth, order) {
            final provider = order ?? OrderProvider();
            provider.updateUser(auth.user?.uid);
            return provider;
          },
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

/// Backwards compatibility alias
typedef ShopEaseApp = StarShopApp;
