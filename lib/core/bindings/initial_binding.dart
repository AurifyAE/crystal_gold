// import 'package:fxg_app/app/controllers/bank_controller.dart';
import 'package:get/get.dart';


import '../controllers/bank_controller.dart';
import '../controllers/conectivity_controller.dart';
import '../controllers/contact_controller.dart';
import '../controllers/live_controller.dart';
import '../controllers/live_rate_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/news_controller.dart';
import '../repositories/live_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put(SplashController());
    Get.put(NavigationController());
    Get.put<BankController>(BankController(), permanent: true);
    Get.put<LiveRepository>(LiveRepository(), permanent: true);
    Get.put<LiveController>(LiveController(), permanent: true);
    Get.put<LiveRateController>(LiveRateController(), permanent: true);
    // Get.put<GoldCarouselController>(GoldCarouselController(), permanent: true);
    Get.put<ConnectivityController>(ConnectivityController(), permanent: true);
    // Get.put<CarouselControllerX>(CarouselControllerX(), permanent: true);
    Get.put<ContactController>(ContactController(), permanent: true);
    Get.put<NewsController>(NewsController(), permanent: true);
  }
}
