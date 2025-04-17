// import '../../models/price_model.dart';

import '../models/price_model.dart';

class PriceCalculator {
  static CommodityPriceModel calculatePrices({
    required String commodityName,
    required Map<String, dynamic>? marketData,
    required dynamic spotRateModel,
    bool isLoading = false,
  }) {
    if (isLoading || marketData == null || spotRateModel == null) {
      return CommodityPriceModel(
        name: commodityName,
        isLoading: true,
      );
    }

    double calculatedBidPrice = 0.0;
    double calculatedAskPrice = 0.0;
    double lowPrice = 0.0;
    double highPrice = 0.0;

    final baseBid =
        marketData['bid'] != null ? (marketData['bid'] as num).toDouble() : 0.0;

    if (commodityName == 'Gold') {
      calculatedBidPrice = baseBid + spotRateModel.info.goldBidSpread;

      calculatedAskPrice =
          calculatedBidPrice + 0.5 + spotRateModel.info.goldAskSpread;
    } else if (commodityName == 'Silver') {
      calculatedBidPrice = baseBid + spotRateModel.info.silverBidSpread;

      calculatedAskPrice =
          calculatedBidPrice + 0.05 + spotRateModel.info.silverAskSpread;
    }

    lowPrice =
        marketData['low'] != null ? (marketData['low'] as num).toDouble() : 0.0;
    highPrice = marketData['high'] != null
        ? (marketData['high'] as num).toDouble()
        : 0.0;

    return CommodityPriceModel(
      name: commodityName,
      bidPrice: calculatedBidPrice,
      askPrice: calculatedAskPrice,
      lowPrice: lowPrice,
      highPrice: highPrice,
      isLoading: false,
    );
  }
}
