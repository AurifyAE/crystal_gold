import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'core/bindings/currency_binding.dart';
import 'core/routes/app_route_management.dart';
import 'core/routes/app_routes.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: _handleNotificationTap,
  );

  runApp(const MyApp());
}

void _handleNotificationTap(NotificationResponse notificationResponse) {
  debugPrint(
      'Notification tapped with payload: ${notificationResponse.payload}');

  switch (notificationResponse.payload) {
    case 'rate_alert':
      Get.toNamed('/main');
      break;
    case 'market_update':
      Get.toNamed('/main');
      break;
    default:
      Get.toNamed('/main');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: 'Crystal Gold',
          // theme: ThemeData(fontFamily: 'Poppins'), 
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          initialBinding: CurrencyBinding(),
          getPages: AppRouteManagement.pages,
        );
      },
    );
  }
}
