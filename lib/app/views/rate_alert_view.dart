import 'package:crystal_gold/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:fxg_app/app/core/utils/app_assets.dart';
import 'package:get/get.dart';

import '../../core/constants/app_assets.dart';
import '../../core/controllers/currency_controller.dart';

// import '../controllers/currency_controller.dart';

class RateAlertView extends StatelessWidget {
  const RateAlertView({super.key});

  @override
  Widget build(BuildContext context) {
    final CurrencyController controller = Get.find<CurrencyController>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,

        middle: Text(
          'Set Gold Rate Alert',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              
              // Gold rate display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey5,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Gold coin image
                        Image.asset(
                          kIcoin,
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback if image is not found
                            return Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEC96C),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD4AF37),
                                  width: 2,
                                ),
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFFF5D76E),
                                    Color(0xFFD4AF37),
                                  ],
                                  radius: 0.8,
                                ),
                              ),
                            );
                          },
                        ),
                        // Rate text overlay on the coin
                        Obx(() => Text(
                          controller.userDefinedRate.value.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.black,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Rate adjustment controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decrease button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: controller.decrementRate,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBlue,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text(
                                '-50',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Current spot rate
                        Obx(() => Text(
                          controller.originalSpotRate.value.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.label,
                          ),
                        )),
                        const SizedBox(width: 20),
                        // Increase button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: controller.incrementRate, 
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBlue,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Text(
                                '+50',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
  
              // Set Alert Button
              Obx(() => CupertinoButton(
                onPressed: controller.isAddingAlert.value
                    ? null
                    : controller.addAlertRate,
                color: const Color(0xFFCD9D34), // Gold button color
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: controller.isAddingAlert.value
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          )
                        : const Text(
                            'Set Alert',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: kCprimary 
                            ),
                          ),
                  ),
                ),
              )),
              
              const SizedBox(height: 20),
              
              // Alert list header
              if (controller.alertRates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0, 
                    right: 16.0, 
                    top: 12.0, 
                    bottom: 8.0
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Your Alerts',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      Text(
                        'Swipe to delete',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Alerts list
              Expanded(
                child: Obx(() => controller.alertRates.isEmpty
                  ? Center(
                      child: Text(
                        'No alerts set',
                        style: TextStyle(
                          color: CupertinoColors.secondaryLabel,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: controller.alertRates.length,
                      itemBuilder: (context, index) {
                        final alertRate = controller.alertRates[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: CupertinoColors.systemGrey5,
                                width: 1,
                              ),
                            ),
                            child: Dismissible(
                              key: Key(alertRate.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20.0),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.destructiveRed,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  CupertinoIcons.delete,
                                  color: CupertinoColors.white, 
                                  size: 22,
                                ),
                              ),
                              onDismissed: (direction) {
                                controller.removeAlertRate(alertRate);
                              },
                              child: CupertinoListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemYellow.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.bell_fill,
                                    color: Color(0xFFCD9D34),
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  alertRate.rate.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Notification will be sent',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                                // trailing: 
                                //  IconButton(onPressed: (){
                                //   controller.removeAlertRate(alertRate);
                                //  }, icon: Icon(CupertinoIcons.delete, color: CupertinoColors.systemGrey, size: 18,))
                                // const Icon(
                                //   CupertinoIcons.chevron_forward,
                                //   color: CupertinoColors.systemGrey,
                                //   size: 18,
                                // ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}