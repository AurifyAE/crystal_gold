import 'package:crystal_gold/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controllers/navigation_controller.dart';
// import '../../controllers/navigation_controller.dart';
// import '../../core/utils/app_colors.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find<NavigationController>();

    // Define nav items with iOS-style icons
    final List<NavItemData> navItems = [ 
      NavItemData(
        icon: CupertinoIcons.chart_bar_fill,
        label: 'Spot Rate',
      ),
      NavItemData(
        icon: CupertinoIcons.bell_fill,
        label: 'Rate Alert',
      ),
      NavItemData(
        icon: CupertinoIcons.person_crop_circle_fill,
        label: 'Contact',
      ),
      NavItemData(
        icon: CupertinoIcons.news_solid,
        label: 'News',
      ),
      NavItemData(
        icon: CupertinoIcons.building_2_fill,
        label: 'Bank Details',
      ),
    ];

    // Custom tab bar with increased height
    return Container(
      height: 80, // Increased height
      decoration: const BoxDecoration(
        color: kCaccent,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 0.5,
          ),
        ),
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final bool isActive = navigationController.currentIndex.value == index;
          return GestureDetector(
            onTap: () => navigationController.changeIndex(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: MediaQuery.of(context).size.width / navItems.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    navItems[index].icon,
                    size: 22, // Decreased icon size
                    color: isActive 
                        ? kCprimary  
                        : CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    navItems[index].label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive 
                          ? kCprimary
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      )),
    );
  }
}

// Simplified NavItemData class for iOS icons
class NavItemData {
  final IconData icon;
  final String label;

  NavItemData({
    required this.icon,
    required this.label,
  });
}