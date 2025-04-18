import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSPriceIndicator extends StatefulWidget {
  final double currentPrice;
  final double previousPrice;

  const IOSPriceIndicator({
    super.key,
    required this.currentPrice,
    required this.previousPrice,
  });

  @override
  State<IOSPriceIndicator> createState() => _IOSPriceIndicatorState();
}

class _IOSPriceIndicatorState extends State<IOSPriceIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  double _previousPrice = 0;
  
  @override
  void initState() {
    super.initState();
    _previousPrice = widget.currentPrice;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: CupertinoColors.systemBackground,
      end: CupertinoColors.systemBackground,
    ).animate(_controller);
  }
  
  @override
  void didUpdateWidget(IOSPriceIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only flash animation if price changed
    if (widget.currentPrice != _previousPrice && widget.currentPrice > 0) {
      Color flashColor;
      
      // Green flash for price increase, red for decrease
      if (widget.currentPrice > _previousPrice) {
        flashColor = CupertinoColors.activeGreen.withOpacity(0.8);
      } else {
        flashColor = CupertinoColors.systemRed.withOpacity(0.8);
      }
      
      _colorAnimation = ColorTween(
        begin: flashColor,
        end: CupertinoColors.systemBackground,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
        ),
      );
      
      _controller.reset();
      _controller.forward();
      _previousPrice = widget.currentPrice;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 110,
          height: 44,
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CupertinoColors.systemGrey5,
              width: 1,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: CupertinoColors.systemGrey5.withOpacity(0.),
            //     blurRadius: 4,
            //     offset: const Offset(0, 1),
            //   ),
            // ],
          ),
          child: Center(
            child: Text(
              widget.currentPrice.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600, 
                color: CupertinoColors.label,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}