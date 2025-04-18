import 'package:crystal_gold/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:fxg_app/app/widgets/spotrate/appbar/date_time.dart';
// import 'package:fxg_app/app/widgets/spotrate/commodities/commodities_list.dart';
import 'package:upgrader/upgrader.dart';

import '../widgets/spot_rate/commodities_list.dart';
import '../widgets/spot_rate/date_time_widget.dart';
import '../widgets/spot_rate/spot_rate_widget.dart';

// import '../core/utils/app_assets.dart';
// import '../widgets/spotrate/appbar/top_bar.dart';
// import '../widgets/spotrate/liverate/spot_rates_widget.dart';

class SpotRateView extends StatelessWidget {
  const SpotRateView({super.key});

  @override
  Widget build(BuildContext context) {
    final upgrader = Upgrader(
      durationUntilAlertAgain: const Duration(days: 3),
      showIgnore: true,
      showLater: true,
      debugDisplayAlways: false,
    );

    return CupertinoPageScaffold(
      
      // navigationBar: CupertinoNavigationBar(
      //   automaticallyImplyLeading: false,
        
      //   middle: Image.asset('assets/images/Crystal Gold Logo-01.png',height: 80,),  
      //   backgroundColor: CupertinoColors.systemBackground,
      //   border: null,
      // ),
      backgroundColor: kCaccent, 
      child: UpgradeAlert(
        upgrader: upgrader,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 12, bottom: 8
                ),
                child: DateTimeWidget(),
              ),
              Expanded(
                flex: 4,
                child: SpotRatesWidget(),
              ),
              Expanded(
                flex: 5,
                child: CommoditiesList(),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}