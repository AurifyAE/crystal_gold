import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
// import 'package:fxg_app/app/core/utils/app_assets.dart';
// import '../controllers/bank_controller.dart';
import '../../core/controllers/bank_controller.dart';
import 'bank_details_view.dart';

class BankView extends StatelessWidget {
  const BankView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BankController>();
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,

        middle: Text('Bank Details'),
        // iOS navigation bars are usually lighter
        backgroundColor: CupertinoColors.systemBackground,
      ),
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                child: Image.asset(
                  'assets/images/Crystal Gold Logo-01.png',
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 80.w, 
                child: Text(
                  'Click the button below to get the bank details for transactions.',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel, 
                  ),
                ),
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                onPressed: () async {
                  await controller.fetchBankDetails();
                  // Using iOS-style push transition
                  Get.to(() => const BankDetailsView(), 
                    transition: Transition.cupertino);
                },
                child: const Text('Get Bank Details'),
              )
            ],
          ),
        ),
      ),
    );
  }
}