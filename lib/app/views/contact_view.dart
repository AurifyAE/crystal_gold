import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fxg_app/app/core/utils/app_assets.dart';
import 'package:get/get.dart';
// import '../controllers/contact_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_color.dart';
import '../../core/controllers/contact_controller.dart';

// import '../widgets/global/custom_appbar.dart';

class ContactView extends GetView<ContactController> {
  @override
  Widget build(BuildContext context) {
    final String userId = Get.arguments ?? '';
    
    // Error message listener
    ever(controller.isLoading, (_) {
      if (!controller.isLoading.value && controller.errorMessage.isNotEmpty) {
        _showIOSStyleAlert(context, 'Error', controller.errorMessage.value);
      }
    });

    // Fetch data after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchContactDetails(userId);
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,

        middle: Text(
          '24/7 Customer Support',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: kCprimary
          ),
        ),
        backgroundColor: kCaccent,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      backgroundColor: kCaccent,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CupertinoActivityIndicator(color: kCprimary,));
        }

        if (controller.contactInfo.value == null) {
          return Center(
            child: Text(
              'Unable to load contact information',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                // Support agent image
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Image.asset(
                    'assets/images/Crystal Gold Logo-01.png',
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.22,
                    fit: BoxFit.contain,
                  ),
                ),
                
                // Support message
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(50, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: CupertinoColors.systemGrey5,
                    //     blurRadius: 5,
                    //     offset: Offset(0, 2),
                    //   ),
                    // ],
                  ),
                  child: Text(
                    'We\'re here to help with any Gold Rate inquiries, support, or feedback. Please contact us via the following channels:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: CupertinoColors.lightBackgroundGray,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Contact options list
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(50, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _buildContactList(),
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContactList() {
    return Column(
      children: [
        _buildContactListTile(
          icon: kiWhatsapp,
          label: 'WhatsApp',
          subtitle: 'Message us directly',
          onTap: () => controller.launchContactUrl(controller.formattedWhatsappUrl),
          showDivider: true,
        ),
        _buildContactListTile(
          icon: kiCall,
          label: 'Call',
          subtitle: 'Speak with a support agent',
          onTap: () => controller.launchContactUrl(controller.formattedPhoneUrl),
          showDivider: true,
        ),
        _buildContactListTile(
          icon: kiMail,
          label: 'Email',
          subtitle: 'Send us your inquiry',
          onTap: () => controller.launchContactUrl(controller.formattedEmailUrl),
          showDivider: true,
        ),
        _buildContactListTile(
          icon: kiLocation,
          label: 'Visit Us',
          subtitle: 'Find our store location',
          onTap: () => controller.launchContactUrl('https://maps.google.com/your-store-location'),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildContactListTile({
    required String icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        CupertinoListTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(97, 242, 242, 247),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
              icon,
              height: 24,
              // ignore: deprecated_member_use
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: kCprimary
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: const Color.fromARGB(153, 167, 167, 167),
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.systemGrey2,
            size: 18,
          ),
          onTap: onTap,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: CupertinoColors.systemGrey5,
            ),
          ),
      ],
    );
  }
  
  void _showIOSStyleAlert(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}