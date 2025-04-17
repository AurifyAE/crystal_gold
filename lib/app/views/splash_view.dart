import 'package:crystal_gold/core/constants/app_color.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCaccent,
      body: Center(
        child: Image.asset('assets/images/Crystal Gold Logo-01.png', width: 50.w,) ,
      ),
    );
  }
}