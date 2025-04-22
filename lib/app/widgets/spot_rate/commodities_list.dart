import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/live_controller.dart';
import '../../../core/controllers/live_rate_controller.dart';
import 'commodity_calculator.dart';

class CommoditiesList extends StatelessWidget {
  const CommoditiesList({super.key});

  @override
  Widget build(BuildContext context) {
    final liveRateController = Get.put(LiveRateController());
    final liveController = Get.put(LiveController());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromARGB(60, 255, 255, 255),
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
                ? _buildLoadingState()
                : _buildCommodityList(liveRateController, liveController);
          },
        ),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: 16),
          Text(
            "Loading commodities data...",
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityList(
      LiveRateController liveRateController, LiveController liveController) {
    final goldData =
        liveRateController.marketData['Gold'] as Map<String, dynamic>?;
    final spotRateModel = liveController.spotRateModel.value;
    final commodityService = CommodityCalculator();

    if (goldData == null || spotRateModel == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: CupertinoColors.systemGrey,
              size: 36,
            ),
            const SizedBox(height: 16),
            const Text(
              'No data available',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 16,
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
    final gmGold750 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'GM', 750);
    final gmGold999 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'GM', 999);
    final gmGold9999 = commodityService.findOrCreateCommodity(commodities, 'Gold', 'GM', 9999);

    final commoditiesList = [
      {
        'name': 'Gold 750',
        'unit': '1 GM',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            gmGold750.sellPremium,
            gmGold750.weight,
            gmGold750.purity,
            gmGold750.sellCharge))
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
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: commoditiesList.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                color: CupertinoColors.systemGrey5.withOpacity(0.3),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final commodity = commoditiesList[index];
                return _buildCommodityRow(
                  commodity['name'] as String,
                  commodity['unit'] as String,
                  commodity['sell'] as double,
                  index,
                );
              },
            ),
          ),
          // _buildFooterInfo(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container( 
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5.withOpacity(0.3), width: 1),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'COMMODITY',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
                fontSize: 14,
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
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityRow(String name, String unit, double sell, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: index.isEven 
          ? Colors.white.withOpacity(0.03) 
          : Colors.white.withOpacity(0.05),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getCommodityColor(name),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis, 
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                // color: CupertinoColors.activeBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "\$ ${sell.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: CupertinoColors.extraLightBackgroundGray, 
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getCommodityColor(String name) {
    if (name.contains('750')) {
      return CupertinoColors.systemYellow;
    } else if (name.contains('999')) {
      return CupertinoColors.systemOrange;
    } else if (name.contains('9999')) {
      return CupertinoColors.activeOrange;
    }
    return CupertinoColors.systemBlue;
  }
  
  // Widget _buildFooterInfo() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //     color: Colors.black.withOpacity(0.2),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: const [
  //         Icon(
  //           CupertinoIcons.info_circle,
  //           color: CupertinoColors.systemGrey,
  //           size: 14,
  //         ),
  //         SizedBox(width: 8),
  //         Text(
  //           "Prices are indicative and subject to change",
  //           style: TextStyle(
  //             color: CupertinoColors.systemGrey,
  //             fontSize: 12,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}