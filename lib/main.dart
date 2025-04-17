import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'core/routes/app_route_management.dart';
import 'core/routes/app_routes.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: 'Crystal Gold',
          theme: ThemeData(fontFamily: 'Poppins'),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          // initialBinding: CurrencyBinding(),
          getPages: AppRouteManagement.pages,
        );
      },
    );
  }
}
