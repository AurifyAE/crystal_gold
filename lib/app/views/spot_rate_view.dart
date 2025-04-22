import 'package:crystal_gold/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

import '../widgets/spot_rate/commodities_list.dart';
import '../widgets/spot_rate/date_time_widget.dart';
import '../widgets/spot_rate/spot_rate_widget.dart';

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
      backgroundColor: kCaccent,
      child: UpgradeAlert(
        upgrader: upgrader,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kCaccent,
                  kCaccent.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DateTimeWidget(),
                ),
                
                // Market rates section
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 8),
                          child: Row(
                            children: const [
                              Icon(
                                CupertinoIcons.chart_bar_alt_fill,
                                color: CupertinoColors.activeBlue,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "LIVE MARKET RATES",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: SpotRatesWidget()),
                      ],
                    ),
                  ),
                ),
                
                // Commodities section
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20, bottom: 0),
                          child: Row(
                            children: const [
                              Icon(
                                CupertinoIcons.money_dollar_circle_fill,
                                color: CupertinoColors.activeGreen,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "COMMODITY PRICES",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: CommoditiesList()),
                      ],
                    ),
                  ),
                ),
                
                // Footer
                  
              ],
            ),
          ),
        ),
      ),
    );
  }
}