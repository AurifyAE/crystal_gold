import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import for number formatting

import '../../../core/constants/app_color.dart';
import '../../../core/controllers/live_controller.dart';
import '../../../core/controllers/live_rate_controller.dart';
import 'commodity_calculator.dart';

class CommoditiesList extends StatelessWidget {
  const CommoditiesList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    final liveRateController = Get.put(LiveRateController());
    final liveController = Get.put(LiveController());

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.03), // 3% of screen width
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: kCaccent  , 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Obx(
          () {
            bool isLoading = liveRateController.marketData.isEmpty ||
                !liveRateController.marketData.containsKey('Gold');

            return isLoading
                ? _buildLoadingState(screenWidth)
                : _buildCommodityList(liveRateController, liveController, screenWidth, screenHeight);
          },
        ),
      ),
    );
  }
  
  Widget _buildLoadingState(double screenWidth) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: screenWidth * 0.04), // Responsive spinner
          SizedBox(height: screenWidth * 0.04),
          Text(
            "Loading commodities data...",
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: _getResponsiveFontSize(screenWidth, 14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityList(
      LiveRateController liveRateController, 
      LiveController liveController,
      double screenWidth,
      double screenHeight) {
      
    final goldData =
        liveRateController.marketData['Gold'] as Map<String, dynamic>?;
    final spotRateModel = liveController.spotRateModel.value;
    final commodityService = CommodityCalculator();
    
    // Initialize formatter for price values
    final priceFormatter = NumberFormat('#,##0.00', 'en_US');

    if (goldData == null || spotRateModel == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: CupertinoColors.systemGrey,
              size: screenWidth * 0.09,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'No data available',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: _getResponsiveFontSize(screenWidth, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    double baseBid =
        goldData['bid'] != null ? (goldData['bid'] as num).toDouble() : 0.0;
    double calculatedBidPrice = baseBid + spotRateModel.info.goldBidSpread;
    double calculatedAskPrice =
        calculatedBidPrice + 0.5 + spotRateModel.info.goldAskSpread;

    final commodities = spotRateModel.info.commodities;
    final ttbGold999 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'TTB', 999);
    final gmGold999 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'GM', 999);
    final gmGold9999 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'GM', 9999);
    final kgGold995 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'KG', 995);
    final kgGold9999 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'KG', 9999);
 
    final commoditiesList = [
      {
        'name': 'Gold Ten TOLA',
        'unit': '1 TTB',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            ttbGold999.sellPremium,
            ttbGold999.weight,
            ttbGold999.purity,
            ttbGold999.sellCharge))
      },
      {
        'name': 'Gold 999',
        'unit': '1 GM',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            gmGold999.sellPremium,
            gmGold999.weight,
            gmGold999.purity,
            gmGold999.sellCharge))
      },
      {
        'name': 'Gold 9999',
        'unit': '1 GM',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            gmGold9999.sellPremium,
            gmGold9999.weight,
            gmGold9999.purity,
            gmGold9999.sellCharge))
      },
      {
        'name': 'Gold 995',
        'unit': '1 KG',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            kgGold995.sellPremium,
            kgGold995.weight,
            kgGold995.purity,
            kgGold995.sellCharge))
      },
      {
        'name': 'Gold 9999',
        'unit': '1 KG',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            kgGold9999.sellPremium,
            kgGold9999.weight,
            kgGold9999.purity,
            kgGold9999.sellCharge))
      },
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(screenWidth),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: commoditiesList.length,
              shrinkWrap: true,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                color: CupertinoColors.systemGrey5.withOpacity(0.3),
                indent: screenWidth * 0.04,
                endIndent: screenWidth * 0.04,
              ),
              itemBuilder: (context, index) {
                final commodity = commoditiesList[index];
                return _buildCommodityRow(
                  commodity['name'] as String,
                  commodity['unit'] as String,
                  commodity['sell'] as double,
                  priceFormatter, // Pass the formatter
                  index,
                  screenWidth,
                  screenHeight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(double screenWidth) {
    return Container( 
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.04, 
        horizontal: screenWidth * 0.05
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'COMMODITY',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(screenWidth, 14),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'UNIT',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(screenWidth, 14),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'SELL PRICE',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(screenWidth, 14),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCommodityRow(
    String name, 
    String unit, 
    double sell,
    NumberFormat formatter, // Add formatter parameter
    int index, 
    double screenWidth,
    double screenHeight) {
      
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02, 
        horizontal: screenWidth * 0.05
      ),
      color: index.isEven 
          ? Colors.white.withOpacity(0.03) 
          : Colors.white.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Container(
                //   width: screenWidth * 0.02,
                //   height: screenHeight * 0.035,
                //   decoration: BoxDecoration(
                //     color: _getCommodityColor(name),
                //     borderRadius: BorderRadius.circular(4),
                //   ),
                // ),
                // SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis, 
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: _getResponsiveFontSize(screenWidth, 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.005, 
                horizontal: screenWidth * 0.02
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                unit,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: _getResponsiveFontSize(screenWidth, 14),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.008, 
                horizontal: screenWidth * 0.03
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatter.format(sell), // Format the price with commas
                style: TextStyle(
                  color: CupertinoColors.extraLightBackgroundGray, 
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(screenWidth, 16),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Color _getCommodityColor(String name) {
  //   if (name.contains('750')) {
  //     return CupertinoColors.systemYellow;
  //   } else if (name.contains('999')) {
  //     return CupertinoColors.systemOrange;
  //   } else if (name.contains('9999')) {
  //     return CupertinoColors.activeOrange;
  //   }
  //   return CupertinoColors.systemBlue;
  // }
  
  // Helper method for responsive font sizing
  double _getResponsiveFontSize(double screenWidth, double baseSize) {
    if (screenWidth < 320) return baseSize * 0.8;
    if (screenWidth < 375) return baseSize * 0.9;
    if (screenWidth > 500) return baseSize * 1.1;
    return baseSize;
  }
}