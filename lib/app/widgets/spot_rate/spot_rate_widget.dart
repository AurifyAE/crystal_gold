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
    // Fix #2: Make sure the loading check and initial data fetch works correctly
    if (liveController.spotRateModel.value == null &&
        !liveController.isLoading.value) {
      liveController.getSpotRate();
    }

    // Fix #3: Add periodic refresh of data
    // Consider adding a timer here to refresh data periodically
    // This is important for real-time price updates

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
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
              // Fix #4: Ensure Obx wrapper is working correctly for reactivity
              child: Obx(() {
                // Fix #5: Add debug prints to help diagnose the issue
                print("Rebuilding rates container");
                print(
                    "Market data empty: ${liveRateController.marketData.isEmpty}");
                print(
                    "Spot rate model null: ${liveController.spotRateModel.value == null}");
                print("Is loading: ${liveController.isLoading.value}");

                return _buildRatesContainer();
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatesContainer() {
    // Fix #6: Better handling of loading and error states
    final hasMarketData = liveRateController.marketData.isNotEmpty;
    final hasSpotRateModel = liveController.spotRateModel.value != null;
    final isLoading =
        !hasMarketData || !hasSpotRateModel || liveController.isLoading.value;

    // Fix #7: Add null-safety checks and fallbacks
    final goldData =
        hasMarketData ? liveRateController.marketData['Gold'] : null;
    final spotRateModel = liveController.spotRateModel.value;

    // Fix #8: Check if PriceCalculator can handle null values correctly
    final goldPriceModel = PriceCalculator.calculatePrices(
      commodityName: 'Gold',
      marketData: goldData,
      spotRateModel: spotRateModel,
      isLoading: isLoading,
    );

    final isGoldMarketClosed =
        goldData != null && goldData["marketStatus"] == "CLOSED";

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          _buildHeaderRow(),

          // Gold Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                // Gold Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildAssetWithLabel(kIgold, 'GOLD'),
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

          // Market Closed Banner (now below gold rate)
          if (isGoldMarketClosed) _buildMarketClosedBanner(),

          // Fix #9: Add a last updated indicator to show data freshness
          // This helps users know if they're looking at stale data
          Expanded(
            child: Center(
              child:
                  isLoading ? const SizedBox() : _buildLastUpdatedIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 80),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  CupertinoIcons.arrow_down_left_square_fill,
                  color: CupertinoColors.activeBlue,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'BID',
                  style: TextStyle(
                    fontSize: 16,
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
              children: const [
                Icon(
                  CupertinoIcons.arrow_up_right_square_fill,
                  color: CupertinoColors.activeGreen,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'ASK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
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
          // Fix #10: Make sure the price indicator widget is properly implemented
          IOSPriceIndicator(
            currentPrice: currentPrice,
            previousPrice: previousPrice,
          ),
          const SizedBox(height: 8),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CupertinoActivityIndicator(radius: 14),
        SizedBox(height: 8),
        Text(
          "Loading...",
          style: TextStyle(
            fontSize: 12,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                fontSize: 12,
                color: isHigherPrice
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemRed,
                fontWeight: FontWeight.w500),
          ),
          Text(
            previousPrice.toStringAsFixed(2),
            style: TextStyle(
                fontSize: 13,
                color: isHigherPrice
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemRed,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetWithLabel(String assetPath, String label) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
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
          // Fix #11: Add better error handling for asset loading
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading asset: $error");
              return Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.photo,
                    color: CupertinoColors.systemGrey2),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketClosedBanner() {
    return Container(
      width: double.infinity,
      color: CupertinoColors.systemRed.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              CupertinoIcons.clock,
              color: CupertinoColors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              'Market is closed. Will open soon!',
              style: TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fix #12: Implement the last updated indicator
  Widget _buildLastUpdatedIndicator() {
    final DateTime now = DateTime.now();
    final String timeString =
        "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
          const Icon(
            CupertinoIcons.refresh,
            color: CupertinoColors.systemGrey,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            "Updated at $timeString",
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
