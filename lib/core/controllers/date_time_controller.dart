import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateTimeController extends GetxController {
  RxString shortDate = ''.obs;
  RxString dayOfWeek = ''.obs;
  RxString time = ''.obs;
  RxString period = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _updateDateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  void _updateDateTime() {
    DateTime now = DateTime.now();
    // Format as "Apr 23"
    shortDate.value = DateFormat('MMM d').format(now);
    // Format as "Wednesday"∏
    dayOfWeek.value = DateFormat('EEEE').format(now);
    // Time without AM/PM
    time.value = DateFormat('hh:mm').format(now);
    // AM/PM period
    period.value = DateFormat('a').format(now);
  }

  @override
  void onClose() {
    super.onClose();
  }
}