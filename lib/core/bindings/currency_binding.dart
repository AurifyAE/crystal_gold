import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../controllers/currency_controller.dart';
import '../controllers/live_rate_controller.dart';
import '../controllers/live_controller.dart';
import '../repositories/notification_service.dart';

class CurrencyBinding implements Bindings {
  @override
  void dependencies() {
    debugPrint('Initializing CurrencyBinding');

    if (!Get.isRegistered<LiveRateController>()) {
      Get.lazyPut<LiveRateController>(() => LiveRateController(), fenix: true);
      debugPrint('LiveRateController registered');
    }

    if (!Get.isRegistered<LiveController>()) {
      Get.lazyPut<LiveController>(() => LiveController(), fenix: true);
      debugPrint('LiveController registered');
    }

    if (!Get.isRegistered<NotificationService>()) {
      Get.lazyPut<NotificationService>(() => NotificationService(),
          fenix: true);
      debugPrint('NotificationService registered');
    }

    Get.lazyPut<DatabaseReference>(() {
      final ref = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            "https://aurify-2-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref('Alert_rate');

      debugPrint('Created Firebase reference at path: ${ref.path}');

      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            "https://aurify-2-default-rtdb.asia-southeast1.firebasedatabase.app",
      ).ref('.info/connected').onValue.listen(
        (event) {
          final connected = event.snapshot.value as bool? ?? false;
          debugPrint(
              'Firebase connection status: ${connected ? "Connected" : "Disconnected"}');
        },
        onError: (error) {
          debugPrint('Firebase connection error: $error');
        },
      );

      return ref;
    }, fenix: true);

    Get.lazyPut<CurrencyController>(() {
      debugPrint('Creating CurrencyController with injected dependencies');
      return CurrencyController(
        liveRateController: Get.find<LiveRateController>(),
        liveController: Get.find<LiveController>(),
        alertRatesRef: Get.find<DatabaseReference>(),
        notificationService: Get.find<NotificationService>(),
      );
    }, fenix: true);

    debugPrint('CurrencyBinding initialization complete');
  }
}
