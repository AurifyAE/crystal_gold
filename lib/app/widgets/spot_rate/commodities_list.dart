import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../../../controllers/live_controller.dart';
// import '../../../controllers/live_rate_controller.dart';
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
        decoration: BoxDecoration(
          // color: const Color.fromARGB(50, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [
          //   BoxShadow(
          //     color: CupertinoColors.systemGrey4.withOpacity(0.3),
          //     blurRadius: 8,
          //     offset: const Offset(0, 2),
          //   ),
          // ],
        ),
        child: Obx(
          () {
            bool isLoading = liveRateController.marketData.isEmpty ||
                !liveRateController.marketData.containsKey('Gold');

            return isLoading
                ? const Center(
                    child: CupertinoActivityIndicator())
                : _buildCommodityList(liveRateController, liveController);
          },
        ),
      ),
    );
  }

  Widget _buildCommodityList(
      LiveRateController liveRateController, LiveController liveController) {
    final goldData =
        liveRateController.marketData['Gold'] as Map<String, dynamic>?;
    final silverData = liveRateController.marketData['Silver'] as Map<String, dynamic>?;
    final spotRateModel = liveController.spotRateModel.value;
    final commodityService = CommodityCalculator();

    if (goldData == null || spotRateModel == null) {
      return const Center(
          child: Text('No data available', 
          style: TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
          )));
    }

    double baseBid =
        goldData['bid'] != null ? (goldData['bid'] as num).toDouble() : 0.0;
    double calculatedBidPrice = baseBid + spotRateModel.info.goldBidSpread;
    double calculatedAskPrice =
        calculatedBidPrice + 0.5 + spotRateModel.info.goldAskSpread;

    double silverBaseBid = silverData!['bid'] != null ? (silverData['bid'] as num).toDouble() : 0.0 ;
    double calculatedSilverBid = silverBaseBid + spotRateModel.info.silverAskSpread;
    double calculatedSilverAsk = calculatedSilverBid + 0.05 + spotRateModel.info.silverAskSpread ;

    final commodities = spotRateModel.info.commodities;
    final gmGold9999 =
        commodityService.findOrCreateCommodity(commodities, "Gold", "GM", 9999);
    final kgGold995 = commodityService.findOrCreateCommodity(
        commodities, "Gold", "KGBAR", 995);
    final kgGold9999 = commodityService.findOrCreateCommodity(
        commodities, "Gold", "KGBAR", 9999);
    final kgTenTola =
        commodityService.findOrCreateCommodity(commodities, "Gold", "TTB", 999);
    final kgSilver9999 =
        commodityService.findOrCreateCommodity(commodities, "Silver", "KGBAR", 9999);

    final commoditiesList = [
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
        'name': 'Gold 9999',
        'unit': '1 KG',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            kgGold9999.sellPremium,
            kgGold9999.weight,
            kgGold9999.purity,
            kgGold9999.sellCharge))
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
        'name': 'Gold TENTOLA',
        'unit': '1 TTB',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedAskPrice,
            kgTenTola.sellPremium,
            kgTenTola.weight,
            kgTenTola.purity,
            kgTenTola.sellCharge))
      },
      {
        'name': 'Silver',
        'unit': '1 KG',
        'sell': double.parse(commodityService.calculateCommodityValue(
            calculatedSilverAsk,
            kgSilver9999.sellPremium,
            kgSilver9999.weight,
            kgSilver9999.purity,
            kgSilver9999.sellCharge))
      }
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: commoditiesList.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.5,
                color: CupertinoColors.systemGrey5,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final commodity = commoditiesList[index];
                return _buildCommodityRow(
                  commodity['name'] as String,
                  commodity['unit'] as String,
                  commodity['sell'] as double,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container( 
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(80, 255, 255, 255),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 1),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
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
            child: Text(
              'SELL',
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

  Widget _buildCommodityRow(String name, String unit, double sell) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: const Color.fromARGB(50, 255, 255, 255),
      child: Row(
        children: [
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
          Expanded(
            child: Text(
              unit,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              sell.toStringAsFixed(2),
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}