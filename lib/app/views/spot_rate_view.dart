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
    // Get screen dimensions for responsive calculations
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive paddings and sizes
    final sidePadding = screenWidth * 0.04; // 4% of screen width
    final sectionSpacing = screenHeight * 0.01; // 1% of screen height
    
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
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
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
                // Date and Time widget with responsive padding
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sidePadding, 
                    vertical: screenHeight * 0.01
                  ),
                  child: DateTimeWidget(),
                ),
                
                // Market rates section - flexible ratio based on screen size
                Expanded(
                  flex: screenHeight < 700 ? 5 : 4, // Adjust ratio for smaller screens
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: sectionSpacing, 
                      bottom: sectionSpacing * 0.8,
                      left: sidePadding * 0.8,
                      right: sidePadding * 0.8
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: sidePadding * 0.5, 
                            bottom: sectionSpacing * 0.8
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.chart_bar_alt_fill,
                                color: CupertinoColors.activeBlue,
                                size: _getAdaptiveIconSize(screenWidth),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "LIVE MARKET RATES",
                                style: TextStyle(
                                  fontSize: _getAdaptiveFontSize(screenWidth, 16),
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
                
                // Commodities section - flexible ratio based on screen size
                Expanded(
                  flex: screenHeight < 700 ? 6 : 5, // Adjust ratio for smaller screens
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: sectionSpacing,
                      left: sidePadding * 0.8,
                      right: sidePadding * 0.8
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: sidePadding * 0.5, 
                            bottom: sectionSpacing * 0.5
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.money_dollar_circle_fill,
                                color: CupertinoColors.activeGreen,
                                size: _getAdaptiveIconSize(screenWidth),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                "COMMODITY PRICES",
                                style: TextStyle(
                                  fontSize: _getAdaptiveFontSize(screenWidth, 16),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
  double _getAdaptiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth < 320) return baseSize * 0.8;
    if (screenWidth < 375) return baseSize * 0.9;
    if (screenWidth > 500) return baseSize * 1.1;
    return baseSize;
  }
  
  // Helper method to get adaptive icon sizes
  double _getAdaptiveIconSize(double screenWidth) {
    if (screenWidth < 320) return 16;
    if (screenWidth < 375) return 17;
    if (screenWidth > 500) return 20;
    return 18;
  }
  }