import 'package:get/get.dart';

import '../../app/views/bank_view.dart';
import '../../app/views/contact_view.dart';
import '../../app/views/main_view.dart';
import '../../app/views/news_view.dart';
import '../../app/views/rate_alert_view.dart';
import '../../app/views/splash_view.dart';
import '../../app/views/spot_rate_view.dart';
import '../bindings/bank_binding.dart';
import '../bindings/contact_binding.dart';
import '../bindings/currency_binding.dart';
import '../bindings/initial_binding.dart';
import '../bindings/live_bindings.dart';
import '../bindings/news_binding.dart';
import '../bindings/splash_binding.dart';
import 'app_routes.dart';

class AppRouteManagement {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => SplashView(), bindings: [
      SplashBinding(),
      BankBinding(),
      LiveBindings(),
    ]),
    GetPage(name: AppRoutes.main, page: () => MainView(), bindings: [
      InitialBinding(),
      BankBinding(),
      LiveBindings(),
    ]),
    GetPage(
      name: AppRoutes.spotRate,
      page: () => SpotRateView(),
       bindings:[ LiveBindings(), BankBinding()]
    ),
    GetPage(name: AppRoutes.rateAlert, page: () => RateAlertView(), bindings: [
      CurrencyBinding(),
      LiveBindings(),
       BankBinding(),
    ]),
    GetPage(
      name: AppRoutes.contact,
      page: () => ContactView(),
       bindings: [ContactBinding(), BankBinding(),LiveBindings()]
    ),
    GetPage(
      name: AppRoutes.news,
      page: () => NewsView(),
       bindings: [NewsBinding(), BankBinding(),LiveBindings()]
    ),
    GetPage(
      name: AppRoutes.bank,
      page: () => BankView(),
       bindings: [BankBinding(),LiveBindings()]
    ),
    // GetPage(
    //   name: AppRoutes.test,
    //   page: () => Test(),
    //    binding: InitialBinding()
    // ),
  ];
}
