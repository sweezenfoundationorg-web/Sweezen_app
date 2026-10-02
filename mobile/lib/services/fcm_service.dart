import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background message handler (Must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("[FCM Background] Title: ${message.notification?.title}");
  debugPrint("[FCM Background] Body: ${message.notification?.body}");
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize Firebase Messaging (FCM)
  static Future<void> initFCM() async {
    try {
      // 1. Request Notification Permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] User authorization status: ${settings.authorizationStatus}');

      // 2. Set Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Get FCM Token & Store
      String? token = await getDeviceToken();
      if (token != null) {
        debugPrint('[FCM Token] $token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }

      // 4. Subscribe to default topic
      await _messaging.subscribeToTopic('all_users');
      debugPrint('[FCM] Subscribed to topic: all_users');

      // 5. Foreground Notification Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground Notification] Title: ${message.notification?.title}');
        debugPrint('[FCM Foreground Notification] Body: ${message.notification?.body}');
        debugPrint('[FCM Foreground Data] Data: ${message.data}');
      });

      // 6. Notification Open Handler (When user clicks notification in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM Opened App] Notification clicked: ${message.notification?.title}');
      });

    } catch (e) {
      debugPrint('[FCM Initialization Error] ${e.toString()}');
    }
  }

  /// Get FCM Device Token
  static Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('[FCM GetToken Error] ${e.toString()}');
      return null;
    }
  }

  /// Subscribe to a custom topic (e.g. 'all_volunteers', 'all_donors')
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[FCM] Subscribed to $topic');
    } catch (e) {
      debugPrint('[FCM Subscribe Error] ${e.toString()}');
    }
  }
}
