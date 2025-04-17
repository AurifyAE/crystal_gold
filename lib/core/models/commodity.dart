class Commodity {
  final String metal;
  final int purity;
  final String weight;
  final double buyPremium;
  final double sellPremium;
  final double buyCharge;
  final double sellCharge;
  
  Commodity({
    required this.metal,
    required this.purity,
    required this.weight,
    required this.buyPremium,
    required this.sellPremium,
    required this.buyCharge,
    required this.sellCharge,
  });
  
  // Factory method to create from dynamic data
  factory Commodity.fromDynamic(dynamic originalCommodity) {
    return Commodity(
      metal: originalCommodity.metal ?? "Gold",
      purity: _ensureIntPurity(originalCommodity.purity),
      weight: originalCommodity.weight ?? "GM",
      buyPremium: _ensureDouble(originalCommodity.buyPremium),
      sellPremium: _ensureDouble(originalCommodity.sellPremium),
      buyCharge: _ensureDouble(originalCommodity.buyCharge),
      sellCharge: _ensureDouble(originalCommodity.sellCharge),
    );
  }
  
  // Clone with potential modifications
  Commodity copyWith({
    String? metal,
    int? purity,
    String? weight,
    double? buyPremium,
    double? sellPremium,
    double? buyCharge,
    double? sellCharge,
  }) {
    return Commodity(
      metal: metal ?? this.metal,
      purity: purity ?? this.purity,
      weight: weight ?? this.weight,
      buyPremium: buyPremium ?? this.buyPremium,
      sellPremium: sellPremium ?? this.sellPremium,
      buyCharge: buyCharge ?? this.buyCharge,
      sellCharge: sellCharge ?? this.sellCharge,
    );
  }
  
  // Helper methods
  static int _ensureIntPurity(dynamic purity) {
    if (purity is int) return purity;
    if (purity is double) return purity.toInt();
    if (purity is String) return int.tryParse(purity) ?? 999;
    return 999; // Default fallback
  }
  
  static double _ensureDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}