import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get to => Get.find();

  final currentIndex = 0.obs;

  final routes = [
    '/spot-rate',
    '/rate-alert',
    '/contact',
    '/news',
    '/bank',
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
    Get.offNamed(routes[index], id: 1);
  }

  String get currentRoute => routes[currentIndex.value];
}
