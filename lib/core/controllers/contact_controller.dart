// import 'package:fxg_app/app/core/constants/constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import '../constants/endpoints.dart';
import '../models/contact_info_model.dart';

// import '../core/constant/constants.dart';
// import '../models/contact_info_model.dart';

class ContactController extends GetxController {
  final Rx<ContactModel?> contactInfo = Rx<ContactModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get formattedWhatsappUrl => contactInfo.value != null
      ? 'https://wa.me/${contactInfo.value!.whatsapp}'
      : '';
  String get formattedPhoneUrl =>
      contactInfo.value != null ? 'tel:+${contactInfo.value!.contact}' : '';

  String get formattedEmailUrl =>
      contactInfo.value != null ? 'mailto:${contactInfo.value!.email}' : '';

  String get formattedlocationUrl =>
      contactInfo.value != null ? 'mailto:${contactInfo.value!.email}' : '';

  Future<void> fetchContactDetails(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final String apiUrl = KConstants.contactUrl;

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: KConstants.headers,
      ).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          contactInfo.value = ContactModel.fromJson(jsonResponse['info']);
          isLoading.value = false;
          errorMessage.value = '';
        } else {
          isLoading.value = false;
          errorMessage.value = jsonResponse['message'] ??
              'Failed to retrieve contact information';
        }
      } else {
        isLoading.value = false;
        errorMessage.value =
            'Failed to connect to server. Status code: ${response.statusCode}';
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An error occurred: ${e.toString()}';
    }
  }

  Future<void> launchContactUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        Get.snackbar(
          'Error',
          'Could not launch $url',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while launching URL',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
