import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

// import '../../../controllers/live_controller.dart';
// import '../../../controllers/live_rate_controller.dart';
import '../../../core/constants/app_assets.dart';
// import '../../../core/utils/app_assets.dart';
// import '../../../core/utils/price_calculator.dart';
// import 'ios_price_indicator.dart';
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
    if (liveController.spotRateModel.value == null &&
        !liveController.isLoading.value) {
      liveController.getSpotRate();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(50, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                // boxShadow: [
                //   BoxShadow(
                //     color: CupertinoColors.systemGrey4.withOpacity(0.3),
                //     blurRadius: 8,
                //     offset: const Offset(0, 2),
                //   ),
                // ],
              ),
              child: Obx(() => _buildRatesContainer()),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRatesContainer() {
    final hasMarketData = liveRateController.marketData.isNotEmpty;
    final hasSpotRateModel = liveController.spotRateModel.value != null;
    final isLoading = !hasMarketData || !hasSpotRateModel || liveController.isLoading.value;
    
    final goldData = hasMarketData ? liveRateController.marketData['Gold'] : null;
    final silverData = hasMarketData ? liveRateController.marketData['Silver'] : null;
    final spotRateModel = liveController.spotRateModel.value;

    final goldPriceModel = PriceCalculator.calculatePrices(
      commodityName: 'Gold',
      marketData: goldData,
      spotRateModel: spotRateModel,
      isLoading: isLoading,
    );

    final silverPriceModel = PriceCalculator.calculatePrices(
      commodityName: 'Silver',
      marketData: silverData,
      spotRateModel: spotRateModel,
      isLoading: isLoading,
    );

    final isGoldMarketClosed = goldData != null && goldData["marketStatus"] == "CLOSED";

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          // _buildSegmentedControl(),
          _buildHeaderRow(),
          
          // Gold Row
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Gold Icon
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildAssetImage(kIgold),
                        ),
                        // Gold Prices
                        Expanded(
                          child: Row(
                            children: [
                              // BID
                              Expanded(
                                child: isLoading
                                  ? _buildLoadingColumn()
                                  : _buildPriceColumn(
                                      title: 'BID',
                                      currentPrice: goldPriceModel.bidPrice,
                                      previousPrice: goldPriceModel.lowPrice,
                                      isHigh: false,
                                      lowHighLabel: 'LOW',
                                    ),
                              ),
                              // ASK
                              Expanded(
                                child: isLoading
                                  ? _buildLoadingColumn()
                                  : _buildPriceColumn(
                                      title: 'ASK',
                                      currentPrice: goldPriceModel.askPrice,
                                      previousPrice: goldPriceModel.highPrice,
                                      isHigh: true,
                                      lowHighLabel: 'HIGH',
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isGoldMarketClosed)
                    _buildMarketClosedBanner(),
                ],
              ),
            ),
          ),
          
          // Silver Row
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Silver Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildAssetImage(kIsilver),
                  ),
                  // Silver Prices
                  Expanded(
                    child: Row(
                      children: [
                        // BID
                        Expanded(
                          child: isLoading
                            ? _buildLoadingColumn()
                            : _buildPriceColumn(
                                title: 'BID',
                                currentPrice: silverPriceModel.bidPrice,
                                previousPrice: silverPriceModel.lowPrice,
                                isHigh: false,
                                lowHighLabel: 'LOW',
                              ),
                        ),
                        // ASK
                        Expanded(
                          child: isLoading
                            ? _buildLoadingColumn()
                            : _buildPriceColumn(
                                title: 'ASK',
                                currentPrice: silverPriceModel.askPrice,
                                previousPrice: silverPriceModel.highPrice,
                                isHigh: true,
                                lowHighLabel: 'HIGH',
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color.fromARGB(80, 255, 255, 255),
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 60),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'BID',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
                SizedBox(width: 4),
                Icon(CupertinoIcons.money_dollar, 
                    color: CupertinoColors.white,

                  // color: CupertinoColors.systemGrey, 
                  size: 16),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'ASK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                                        color: CupertinoColors.white,

                  ),
                ),
                SizedBox(width: 4),
                Icon(CupertinoIcons.money_dollar, 
                                     color: CupertinoColors.white,
 
                  size: 16),
              ],
            ),
          ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IOSPriceIndicator(
            currentPrice: currentPrice,
            previousPrice: previousPrice,
          ),
          const SizedBox(height: 4),
          _buildPreviousPriceIndicator(
            previousPrice: previousPrice,
            isHigherPrice: isHigh,
            label: lowHighLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingColumn() {
    return const Center(
      child: CupertinoActivityIndicator(),
    );
  }

  Widget _buildPreviousPriceIndicator({
    required double previousPrice,
    required bool isHigherPrice,
    required String label,
  }) {
    return Text(
      '$label ${previousPrice.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 13,
        color: isHigherPrice 
            ? CupertinoColors.systemGreen 
            : CupertinoColors.systemRed,
        fontWeight: FontWeight.w500
      ),
    );
  }

  Widget _buildAssetImage(String assetPath) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        // color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: CupertinoColors.systemGrey4.withOpacity(0.2),
        //     blurRadius: 4,
        //     offset: const Offset(0, 1),
        //   ),
        // ],
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 50,
            width: 50,
            color: CupertinoColors.systemGrey5,
            child: const Icon(CupertinoIcons.photo, 
              color: CupertinoColors.systemGrey2),
          );
        },
      ),
    );
  }

  Widget _buildMarketClosedBanner() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        child: Container(
          color: CupertinoColors.systemRed.withOpacity(0.8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: Text(
                'Market is closed. Will open soon!',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}