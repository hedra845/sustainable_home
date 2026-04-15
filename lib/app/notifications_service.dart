import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
}

class NotificationsService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Initialize Firebase
    // Note: User needs to run 'flutterfire configure' to generate firebase_options.dart
    // For now, we assume Firebase is initialized with default options or handled elsewhere
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // Might fail if options are not provided
    }

    // 2. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Initialize Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click
      },
    );

    // 4. Create Android Notification Channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 5. Setup Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  static Future<void> requestPermissions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasRequested = prefs.getBool('notifications_requested') ?? false;

    if (!hasRequested) {
      // Request Firebase Messaging Permission
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Also use permission_handler for local permissions if needed (Android 13+)
      if (Platform.isAndroid) {
        await Permission.notification.request();
      }

      await prefs.setBool('notifications_requested', true);
    }
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
