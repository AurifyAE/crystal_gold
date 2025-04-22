import 'dart:math';
import 'dart:developer' as dev;

import '../../../core/models/commodity.dart';

// import '../../../models/commodity.dart';

class CommodityCalculator {
  Commodity findOrCreateCommodity(
    List<dynamic> commodities, String metal, String weight, int purity,
    {double? premium}) {
  dev.log('🔍 Finding commodity: metal=$metal, weight=$weight, purity=$purity, premium=$premium');
  
  dynamic foundCommodity;

  try {
    // First try to find an exact match by metal, weight AND purity
    for (var commodity in commodities) {
      if (commodity.metal == metal && 
          commodity.weight == weight && 
          commodity.purity == purity) {
        dev.log('✅ Found exact match for ${commodity.metal}, ${commodity.weight}, ${commodity.purity}');
        return Commodity.fromDynamic(commodity);
      }
    }
    
    // If no exact match by purity, look for metal and weight match
    for (var commodity in commodities) {
      if (commodity.metal == metal && commodity.weight == weight) {
        dev.log('✅ Found match for ${commodity.metal}, ${commodity.weight}');
        foundCommodity = commodity;
        break;
      }
    }

    // If still not found, search for closest match
    if (foundCommodity == null) {
      dev.log('🔎 No exact match found, searching for closest match');
      foundCommodity = commodities.firstWhere(
          (c) => c.metal == metal && (c.weight == weight || weight == "GM"),
          orElse: () => commodities.firstWhere((c) => c.metal == metal,
              orElse: () => commodities.first));
    }
  } catch (e) {
    dev.log('❌ Error finding commodity: $e');
    foundCommodity = commodities.first;
  }

  dev.log('📊 Using base commodity: ${foundCommodity.metal}, ${foundCommodity.weight}, ${foundCommodity.purity}');
  Commodity baseCommodity = Commodity.fromDynamic(foundCommodity);

  // Remove buy premium for KGBAR
  double? finalPremium = weight == "KGBAR" ? 0 : premium;
  
  // Always create a new commodity with the specified purity
  Commodity result = baseCommodity.copyWith(
      purity: purity, weight: weight, buyPremium: finalPremium);
  dev.log('🆕 Created new commodity: ${result.metal}, ${result.weight}, ${result.purity}, premium=${result.buyPremium}');
  
  return result;
}

  double calculatePurityPower(dynamic purity) {
    String purityStr = purity.toString();
    int digitCount = purityStr.length;
    double powerOfTen = pow(10, digitCount).toDouble();
    double result = purity / powerOfTen;
    
    dev.log('🧮 Purity calculation: purity=$purity, digits=$digitCount, power=$powerOfTen, result=$result');
    return result;
  }

  double getUnitMultiplier(String weight) {
    double multiplier;
    
    switch (weight) {
      case "GM":
        multiplier = 1.0;
        break;
      case "KG":
        multiplier = 1000.0;
        break;
      case "KGBAR":
        multiplier = 1000.0; // Changed from 999.0 to be consistent with KG
        break;
      case "TTB":
      case "TTBAR":
        multiplier = 116.64;
        break;
      case "TOLA":
        multiplier = 11.664;
        break;
      case "OZ":
        multiplier = 31.1034768;
        break;
      default:
        multiplier = 1.0;
        break;
    }
    
    dev.log('⚖️ Unit multiplier for $weight: $multiplier');
    return multiplier;
  }

  String formatValue(double value, String weight) {
    String formatted;
    
    if (weight == "GM") {
      formatted = value.toStringAsFixed(2);
    } else {
      formatted = value.toStringAsFixed(0);
    }
    
    dev.log('🔢 Formatting value $value for $weight: $formatted');
    return formatted;
  }

  String calculateCommodityValue(double bidPrice, double buyPremium,
      String weight, int purity, double buyCharge) {
    dev.log('💰 Calculating commodity value: bidPrice=$bidPrice, buyPremium=$buyPremium, weight=$weight, purity=$purity, buyCharge=$buyCharge');
    
    // Apply zero premium for KGBAR
    double effectiveBuyPremium = weight == "KGBAR" ? 0 : buyPremium;
    dev.log('💸 Effective buy premium: $effectiveBuyPremium (original: $buyPremium)');
    
    double cat = bidPrice + effectiveBuyPremium;
    dev.log('🏷️ CAT value (bidPrice + premium): $cat');
    
    double bidNow = (cat / 31.103) * 3.674;
    dev.log('📈 BidNow ((cat / 31.103) * 3.674): $bidNow');
    
    double unitMultiplier = getUnitMultiplier(weight);
    double purityFactor = calculatePurityPower(purity);
    
    dev.log('📊 Calculation factors: unitMultiplier=$unitMultiplier, purityFactor=$purityFactor');
    
    double rateNow = bidNow * unitMultiplier * purityFactor + buyCharge;
    dev.log('💲 rateNow before formatting: $rateNow');
    
    String formattedPrice = formatValue(rateNow, weight);
    dev.log('✅ Final formatted price: $formattedPrice');
    
    return formattedPrice;
  }
}