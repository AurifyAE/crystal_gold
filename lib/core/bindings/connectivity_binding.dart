import 'package:get/get.dart';

import '../controllers/conectivity_controller.dart';

class ConnectivityBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ConnectivityController());
  }
}
