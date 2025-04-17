import 'package:get/get.dart';
// import 'package:yakoot_jewellery/app/controllers/contact_controller.dart';

import '../controllers/contact_controller.dart';

class ContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ContactController>(ContactController(), permanent: true);
  }
}
