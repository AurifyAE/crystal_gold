import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class IOSPriceIndicator extends StatefulWidget {
  final double currentPrice;
  final double previousPrice;
  final Duration flashDuration;

  const IOSPriceIndicator({
    Key? key,
    required this.currentPrice,
    required this.previousPrice,
    this.flashDuration = const Duration(milliseconds: 1000),
  }) : super(key: key);

  @override
  State<IOSPriceIndicator> createState() => _IOSPriceIndicatorState();
}

class _IOSPriceIndicatorState extends State<IOSPriceIndicator> {
  late double _displayedPrice;
  late Color _backgroundColor;
  late Color _textColor;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _displayedPrice = widget.currentPrice;
    _setNeutralState();
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(IOSPriceIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only trigger animation when the price actually changes
    if (widget.currentPrice != oldWidget.currentPrice) {
      _displayedPrice = widget.currentPrice;
      
      if (widget.currentPrice > oldWidget.currentPrice) {
        _setIncreaseState();
      } else if (widget.currentPrice < oldWidget.currentPrice) {
        _setDecreaseState();
      }
    }
  }

  void _setIncreaseState() {
    setState(() {
      _backgroundColor = CupertinoColors.systemGreen;
      _textColor = CupertinoColors.white;
    });
    _resetAfterFlash();
  }

  void _setDecreaseState() {
    setState(() {
      _backgroundColor = CupertinoColors.systemRed;
      _textColor = CupertinoColors.white;
    });
    _resetAfterFlash();
  }

  void _setNeutralState() {
    setState(() {
      _backgroundColor = CupertinoColors.white;
      _textColor = CupertinoColors.black;
    });
  }

  void _resetAfterFlash() {
    // Cancel any existing timer
    _flashTimer?.cancel();
    
    // Set a new timer
    _flashTimer = Timer(widget.flashDuration, () {
      if (mounted) {
        _setNeutralState();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _displayedPrice.toStringAsFixed(2),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _textColor,
        ),
      ),
    );
  }
}