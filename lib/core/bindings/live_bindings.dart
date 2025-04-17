import 'package:get/get.dart';
import '../controllers/live_controller.dart';
import '../controllers/live_rate_controller.dart';
import '../repositories/live_repository.dart';

class LiveBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<LiveRepository>(LiveRepository(), permanent: true);
    Get.put<LiveController>(LiveController(), permanent: true);
    Get.put<LiveRateController>(LiveRateController(), permanent: true);
  }
}
