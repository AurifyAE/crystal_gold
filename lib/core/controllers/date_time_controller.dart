import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateTimeController extends GetxController {
  RxString formattedDate = ''.obs;
  RxString formattedTime = ''.obs;

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
    formattedDate.value = DateFormat('EEEE, MMM d').format(now);
    formattedTime.value = DateFormat('HH:mm').format(now);
  }
}
