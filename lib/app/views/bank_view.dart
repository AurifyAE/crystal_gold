import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../../core/controllers/bank_controller.dart';

class BankView extends StatelessWidget {
  const BankView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BankController>();
    
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text('Bank Details'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      backgroundColor: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Center(
          child: Obx(() => Column(
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
              
              // Show error message if there's an error
              if (controller.hasError.value)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 14,
                    ),
                  ),
                ),
                
              const SizedBox(height: 15),
              
              controller.isLoading.value
                ? const CupertinoActivityIndicator(radius: 15)
                : CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(10),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    onPressed: () => controller.fetchBankDetails(),
                    child: const Text('Get Bank Details'),
                  )
            ],
          )),
        ),
      ),
    );
  }
}