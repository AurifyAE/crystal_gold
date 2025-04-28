import 'package:crystal_gold/core/constants/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/controllers/bank_controller.dart';
import '../widgets/bank/ios_card.dart';

class BankDetailsView extends StatelessWidget {
  const BankDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BankController>();
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Bank Details', style: TextStyle(color: kCprimary),),
        backgroundColor: CupertinoColors.systemBackground,
        previousPageTitle: 'Back', 
        leading: const CupertinoNavigationBarBackButton(
          color: Colors.white,
        ), // iOS-style back button text
      ),
      backgroundColor: kCaccent,  // iOS grouped background color
      child: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CupertinoActivityIndicator());
          }
          
          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${controller.errorMessage.value}',
                    style: const TextStyle(color: CupertinoColors.destructiveRed),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton(
                    onPressed: controller.fetchBankDetails,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          if (controller.bankResponse.value == null || 
              controller.bankResponse.value!.bankInfo.bankDetails.isEmpty) {
            // Display empty state with icon and text
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.building_2_fill,
                    size: 70,
                    color: CupertinoColors.systemGrey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No bank details available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 212, 212, 212),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your bank information will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 212, 212, 212),
                    ),
                  ),
                ],
              ),
            );
          }
          
          final bankDetails = controller.bankResponse.value!.bankInfo.bankDetails;
          
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return IOSBankCard(bankDetails: bankDetails[index]);
                  },
                  childCount: bankDetails.length,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}