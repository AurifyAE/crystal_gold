import 'package:flutter/material.dart';

enum PriceChangeState {
  neutral,

  increase,

  decrease,
}

extension PriceChangeStateExtension on PriceChangeState {
  Color get color {
    switch (this) {
      case PriceChangeState.increase:
        return Colors.green;
      case PriceChangeState.decrease:
        return Colors.red;
      case PriceChangeState.neutral:
        return Colors.white;
    }
  }

  bool get isChanged => this != PriceChangeState.neutral;
}
