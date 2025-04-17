import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/controllers/bank_controller.dart';
import '../widgets/bank/ios_card.dart';
// import '../controllers/bank_controller.dart';
// import '../models/bank_model.dart';

class BankDetailsView extends StatelessWidget {
  const BankDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BankController>();
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Bank Details'),
        backgroundColor: CupertinoColors.systemBackground,
        previousPageTitle: 'Back', // iOS-style back button text
      ),
      backgroundColor: CupertinoColors.systemGroupedBackground, // iOS grouped background color
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
          
          if (controller.bankResponse.value == null) {
            return const Center(child: Text('No bank details available'));
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