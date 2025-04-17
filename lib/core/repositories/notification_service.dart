import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      debugPrint('Initializing notification service');
      const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );
      _initialized = true;
      debugPrint('Notifications initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<bool> requestPermissions() async {
    try {
      debugPrint('Requesting notification permissions');
      
      // Request permissions for iOS
      final iOS = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iOS != null) {
        final result = await iOS.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('iOS notification permissions result: $result');
      }

      // Request permissions for Android 13+
      final android = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final result = await android.requestNotificationsPermission();
        debugPrint('Android notification permissions result: $result');
      }
      
      debugPrint('Notification permissions requested successfully');
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  Future<void> showNotification({
    required String title, 
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('Notifications not initialized yet, initializing now...');
      await _initializeNotifications();
      await requestPermissions();
    }

    try {
      debugPrint('Preparing to show notification: $title - $body');
      
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'gold_rate_alerts',
        'Gold Rate Alerts',
        channelDescription: 'Notifications for gold rate alerts',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
      );
      
      const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
      debugPrint('Sending notification with ID: $notificationId');
      
      await flutterLocalNotificationsPlugin.show(
        notificationId, // Use a unique ID based on current time 
        title, 
        body, 
        platformChannelSpecifics,
        payload: payload ?? 'rate_alert',
      );
      
      debugPrint('Notification sent successfully: $title - $body');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
  
  // Method to check if notifications are working
  Future<void> sendTestNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification to verify the system is working',
      payload: 'test',
    );
  }
}