// lib/app/modules/bank/bindings/bank_binding.dart

import 'package:get/get.dart';
import '../controllers/bank_controller.dart';

class BankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BankController>(
      () => BankController(),
    );
  }
}