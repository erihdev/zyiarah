import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      // NOTE: Firebase.initializeApp() usually needs google-services.json
      // If not present, this will catch and log.
      
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permissions');
        
        // Get FCM Token
        String? token = await _fcm.getToken();
        debugPrint('FCM Token: $token');
        
        // TODO: Send token to Supabase users table to target this device
      }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.notification?.title}');
        // You could show a local notification here
      });

      // Handle tapping a notification when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Notification tapped: ${message.data}');
        _handleDeepLink(message.data);
      });

    } catch (e) {
      debugPrint('Firebase Notification Init failed: $e');
      debugPrint('TIP: Ensure google-services.json (Android) or GoogleService-Info.plist (iOS) are added to the project.');
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    // Basic deep linking logic
    final String? screen = data['screen'];
    final String? id = data['id'];
    
    // In a real app, you'd use a navigator key or a router service to navigate
    debugPrint('App should navigate to $screen with ID $id');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}
