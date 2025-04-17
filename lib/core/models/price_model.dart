class CommodityPriceModel {
  final String name;
  final double bidPrice;
  final double askPrice;
  final double lowPrice;
  final double highPrice;
  final bool isLoading;

  CommodityPriceModel({
    required this.name,
    this.bidPrice = 0.0,
    this.askPrice = 0.0,
    this.lowPrice = 0.0,
    this.highPrice = 0.0,
    this.isLoading = true,
  });

  CommodityPriceModel copyWith({
    String? name,
    double? bidPrice,
    double? askPrice,
    double? lowPrice,
    double? highPrice,
    bool? isLoading,
  }) {
    return CommodityPriceModel(
      name: name ?? this.name,
      bidPrice: bidPrice ?? this.bidPrice,
      askPrice: askPrice ?? this.askPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      highPrice: highPrice ?? this.highPrice,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}