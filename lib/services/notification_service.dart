import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling background FCM message: ${message.messageId}');
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  static const String channelId = 'shopease_high_importance_channel';
  static const String channelName = 'ShopEase Notifications';
  static const String channelDescription =
      'This channel is used for important ShopEase order and promotional notifications.';

  // Initialize notifications
  Future<void> initialize() async {
    try {
      // 1. Request FCM notification permission
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('User notification permission status: ${settings.authorizationStatus}');
      }

      // 2. Fetch FCM Token
      try {
        _fcmToken = await _fcm.getToken();
        if (kDebugMode) {
          print('FCM Registration Token: $_fcmToken');
        }
      } catch (tokenError) {
        if (kDebugMode) {
          print('Could not retrieve FCM token: $tokenError');
        }
      }

      // 3. Configure Local Notifications for Android/iOS foreground display
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );

      // Create Android Notification Channel
      if (!kIsWeb && Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDescription,
          importance: Importance.high,
          playSound: true,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }

      // 4. Handle Foreground FCM Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Received foreground message: ${message.notification?.title}');
        }
        final notification = message.notification;

        if (notification != null && !kIsWeb) {
          showNotification(
            title: notification.title ?? 'ShopEase Update',
            body: notification.body ?? '',
            payload: message.data.toString(),
          );
        }
      });

      // 5. Handle Background Message Entry Point
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    } catch (e) {
      if (kDebugMode) {
        print('NotificationService initialization warning: $e');
      }
    }
  }

  // Display a local notification (e.g. on order placed)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error displaying notification: $e');
      }
    }
  }

  // Show order placed notification helper
  Future<void> showOrderPlacedNotification({
    required String orderId,
    required double total,
  }) async {
    await showNotification(
      id: orderId.hashCode,
      title: 'Order Placed Successfully! 🎉',
      body: 'Order #$orderId for \$${total.toStringAsFixed(2)} is confirmed and being prepared.',
      payload: orderId,
    );
  }
}
