import 'package:crystal_gold/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

// Fix #1: Check these import paths to ensure they match the actual project structure
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/price_calculator.dart';
import '../../../core/controllers/live_controller.dart';
import '../../../core/controllers/live_rate_controller.dart';
import 'price_indicator_widget.dart';

class SpotRatesWidget extends StatelessWidget {
  final liveRateController = Get.find<LiveRateController>();
  final liveController = Get.find<LiveController>();

  SpotRatesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Make sure the loading check and initial data fetch works correctly
    if (liveController.spotRateModel.value == null &&
        !liveController.isLoading.value) {
      liveController.getSpotRate();
    }

    // Add periodic refresh of data if needed
    // Consider implementing with a timer

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Container(
              decoration: BoxDecoration(
                color: kCaccent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() {
                return _buildRatesContainer(screenWidth, screenHeight);
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatesContainer(double screenWidth, double screenHeight) {
    // Better handling of loading and error states
    final hasMarketData = liveRateController.marketData.isNotEmpty;
    final hasSpotRateModel = liveController.spotRateModel.value != null;
    final isLoading =
        !hasMarketData || !hasSpotRateModel || liveController.isLoading.value;

    // Add null-safety checks and fallbacks
    final goldData =
        hasMarketData ? liveRateController.marketData['Gold'] : null;
    final spotRateModel = liveController.spotRateModel.value;

    // Check if PriceCalculator can handle null values correctly
    final goldPriceModel = PriceCalculator.calculatePrices(
      commodityName: 'Gold',
      marketData: goldData,
      spotRateModel: spotRateModel,
      isLoading: isLoading,
    );

    final isGoldMarketClosed =
        goldData != null && goldData["marketStatus"] == "CLOSED";

    final headerHeight = screenHeight * 0.06;
    final rowHeight = screenHeight * 0.15;
    final iconSize = screenWidth < 360 ? screenWidth * 0.11 : screenWidth * 0.09;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          // Header with responsive heights
          Container(
            height: headerHeight,
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.012, 
              horizontal: screenWidth * 0.04
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: const Border(
                bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: screenWidth * 0.2),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                      Text(
                        '\$', 
                        style: TextStyle(
                          fontSize: _getAdaptiveFontSize(screenWidth, 16),
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        'BID',
                        style: TextStyle(
                          fontSize: _getAdaptiveFontSize(screenWidth, 16),
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$', 
                        style: TextStyle(
                          fontSize: _getAdaptiveFontSize(screenWidth, 16),
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        'ASK',
                        style: TextStyle(
                          fontSize: _getAdaptiveFontSize(screenWidth, 16),
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gold Row with responsive design
          Container(
            height: rowHeight,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              border: const Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Gold Icon with responsive size
                Container(
                  width: screenWidth * 0.2,
                  child: _buildAssetWithLabel(
                    kIcoin,  
                    'GOLD', 
                    iconSize, 
                    screenWidth
                  ),
                ),
                // Gold Prices
                Expanded(
                  child: Row(
                    children: [
                      // BID
                      Expanded(
                        child: isLoading
                            ? _buildLoadingColumn(screenWidth)
                            : _buildPriceColumn(
                                title: 'BID',
                                currentPrice: goldPriceModel.bidPrice,
                                previousPrice: goldPriceModel.lowPrice,
                                isHigh: false,
                                lowHighLabel: 'LOW',
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                              ),
                      ),
                      // ASK
                      Expanded(
                        child: isLoading
                            ? _buildLoadingColumn(screenWidth)
                            : _buildPriceColumn(
                                title: 'ASK',
                                currentPrice: goldPriceModel.askPrice,
                                previousPrice: goldPriceModel.highPrice,
                                isHigh: true,
                                lowHighLabel: 'HIGH',
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Market Closed Banner (now below gold rate)
          if (isGoldMarketClosed) _buildMarketClosedBanner(screenWidth),

          // Last updated indicator
          // Center(
          //   child:
          //       isLoading ? const SizedBox() : _buildLastUpdatedIndicator(screenWidth),
          // ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn({
    required String title,
    required double currentPrice,
    required double previousPrice,
    required bool isHigh,
    required String lowHighLabel,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Price indicator with responsive sizes
          IOSPriceIndicator(
            currentPrice: currentPrice,
            previousPrice: previousPrice,
            // fontSize: _getAdaptiveFontSize(screenWidth, 18),
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildPreviousPriceIndicator(
            previousPrice: previousPrice,
            isHigherPrice: isHigh,
            label: lowHighLabel,
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingColumn(double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoActivityIndicator(radius: screenWidth * 0.035),
        SizedBox(height: screenWidth * 0.02),
        Text(
          "Loading...",
          style: TextStyle(
            fontSize: _getAdaptiveFontSize(screenWidth, 12),
            color: CupertinoColors.systemGrey,
          ),
        )
      ],
    );
  }

  Widget _buildPreviousPriceIndicator({
    required double previousPrice,
    required bool isHigherPrice,
    required String label,
    required double screenWidth,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02, 
        vertical: screenWidth * 0.01
      ),
      decoration: BoxDecoration(
        color: (isHigherPrice
                ? CupertinoColors.systemGreen
                : CupertinoColors.systemRed)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: (isHigherPrice
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemRed)
              .withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label ',
            style: TextStyle(
                fontSize: _getAdaptiveFontSize(screenWidth, 12),
                color: isHigherPrice
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemRed,
                fontWeight: FontWeight.w500),
          ),
          Text(
            previousPrice.toStringAsFixed(2),
            style: TextStyle(
                fontSize: _getAdaptiveFontSize(screenWidth, 13),
                color: isHigherPrice
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemRed,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetWithLabel(
    String assetPath, 
    String label, 
    double size,
    double screenWidth
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // Add better error handling for asset loading
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading asset: $error");
              return Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.photo,
                  color: CupertinoColors.systemGrey2,
                  size: size * 0.6,
                ),
              );
            },
          ),
        ),
        SizedBox(height: size * 0.12),
        Text(
          label,
          style: TextStyle(
            fontSize: _getAdaptiveFontSize(screenWidth, 12),
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketClosedBanner(double screenWidth) {
    return Container(
      width: double.infinity,
      color: CupertinoColors.systemRed.withOpacity(0.8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.clock,
              color: CupertinoColors.white,
              size: screenWidth * 0.04,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              'Market is closed. Will open soon!',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: _getAdaptiveFontSize(screenWidth, 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fix #12: Implement the last updated indicator
 Widget _buildLastUpdatedIndicator(double screenWidth) {
    final DateTime now = DateTime.now();
    final String timeString =
        "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.015, 
        horizontal: screenWidth * 0.03
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.refresh,
            color: CupertinoColors.systemGrey,
            size: screenWidth * 0.03,
          ),
          SizedBox(width: screenWidth * 0.01),
          Text(
            "Updated at $timeString",
            style: TextStyle(
              fontSize: _getAdaptiveFontSize(screenWidth, 12),
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method for adaptive font sizing
  double _getAdaptiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth < 320) return baseSize * 0.8;  // Very small screens
    if (screenWidth < 375) return baseSize * 0.9;  // Small screens
    if (screenWidth > 500) return baseSize * 1.1;  // Large screens
    return baseSize;  // Medium screens (default)
  }
}

// Responsive DateTimeWidget
// class DateTimeWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final date = DateTime.now();
//     final formattedDate = "${_getMonth(date.month)} ${date.day}, ${date.year}";
    
//     return Container(
//       padding: EdgeInsets.symmetric(
//         vertical: screenWidth * 0.02, 
//         horizontal: screenWidth * 0.04
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Date display
//           Row(
//             children: [
//               Icon(
//                 CupertinoIcons.calendar,
//                 color: CupertinoColors.systemGrey,
//                 size: _getAdaptiveIconSize(screenWidth),
//               ),
//               SizedBox(width: screenWidth * 0.02),
//               Text(
//                 formattedDate,
//                 style: TextStyle(
//                   color: CupertinoColors.white,
//                   fontSize: _getAdaptiveFontSize(screenWidth, 14),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
          
//           // Animated clock
//           StreamBuilder(
//             stream: Stream.periodic(const Duration(seconds: 1)),
//             builder: (context, snapshot) {
//               final now = DateTime.now();
//               final hour = now.hour.toString().padLeft(2, '0');
//               final minute = now.minute.toString().padLeft(2, '0');
//               final second = now.second.toString().padLeft(2, '0');
              
//               return Row(
//                 children: [
//                   Icon(
//                     CupertinoIcons.clock,
//                     color: CupertinoColors.systemGrey,
//                     size: _getAdaptiveIconSize(screenWidth),
//                   ),
//                   SizedBox(width: screenWidth * 0.02),
//                   Text(
//                     "$hour:$minute:$second",
//                     style: TextStyle(
//                       color: CupertinoColors.activeBlue,
//                       fontSize: _getAdaptiveFontSize(screenWidth, 14),
//                       fontWeight: FontWeight.w600,
//                       fontFeatures: [FontFeature.tabularFigures()],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

  double _getAdaptiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth < 320) return baseSize * 0.8;
    if (screenWidth < 375) return baseSize * 0.9;
    if (screenWidth > 500) return baseSize * 1.1;
    return baseSize;
  }
  
  double _getAdaptiveIconSize(double screenWidth) {
    if (screenWidth < 320) return 14;
    if (screenWidth < 375) return 16;
    if (screenWidth > 500) return 18;
    return 16;
  }
  
// }

// Responsive Price Indicator Widget
