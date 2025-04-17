import 'package:flutter/material.dart';
// import 'package:fxg_app/app/views/bank_view.dart';
import 'package:get/get.dart';

// import '../controllers/navigation_controller.dart';
import '../../core/controllers/navigation_controller.dart';
import '../widgets/global/custom_navbar.dart';
import 'bank_view.dart';
import 'contact_view.dart';
import 'news_view.dart';
import 'rate_alert_view.dart';
import 'spot_rate_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();

    return Scaffold(
      body: Navigator(
        key: Get.nestedKey(1),
        initialRoute: navigationController.routes[0],
        onGenerateRoute: (settings) {
          Widget page;
          switch (settings.name) {
            case '/spot-rate':
              page = SpotRateView();
              break;
            case '/rate-alert':
              page = RateAlertView();
              break;
            case '/contact':
              page = ContactView();
              break;
            case '/news':
              page = NewsView();
              break;
            case '/bank':
              page = const BankView();
              break;
            default:
              page = SpotRateView();
          }

          return GetPageRoute(
            page: () => page,
            transition: Transition.native,  
            transitionDuration: const Duration(milliseconds: 300),
            settings: settings,
          );
        },
      ),
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
