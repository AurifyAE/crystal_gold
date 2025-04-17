import 'dart:async';
import 'package:get/get.dart';

import '../models/price_change_state.dart';

class PriceAnimationController {
  final String commodityName;
  final String priceType;
  final int flashDuration;

  late RxDouble previousValue;
  late RxString colorState;

  PriceAnimationController({
    required this.commodityName,
    required this.priceType,
    this.flashDuration = 500,
  }) {
    _initializeController();
  }

  void _initializeController() {
    final tagName = '${commodityName}_${priceType}_prevValue';

    if (Get.isRegistered<RxDouble>(tag: tagName)) {
      previousValue = Get.find<RxDouble>(tag: tagName);
    } else {
      previousValue = 0.0.obs;
      Get.put<RxDouble>(previousValue, tag: tagName);
    }

    colorState = PriceChangeState.neutral.toString().obs;
  }

  void updatePrice(double newPrice) {
    if (newPrice > previousValue.value) {
      colorState.value = PriceChangeState.increase.toString();
      _resetStateAfterFlash();
    } else if (newPrice < previousValue.value) {
      colorState.value = PriceChangeState.decrease.toString();
      _resetStateAfterFlash();
    }

    previousValue.value = newPrice;
  }

  void _resetStateAfterFlash() {
    Timer(Duration(milliseconds: flashDuration), () {
      colorState.value = PriceChangeState.neutral.toString();
    });
  }

  PriceChangeState get currentState {
    switch (colorState.value) {
      case 'PriceChangeState.increase':
        return PriceChangeState.increase;
      case 'PriceChangeState.decrease':
        return PriceChangeState.decrease;
      default:
        return PriceChangeState.neutral;
    }
  }
}
