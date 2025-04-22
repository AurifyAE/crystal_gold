import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../app/views/bank_details_view.dart';
import '../constants/endpoints.dart';
import '../models/bank_model.dart';
// import 'bank_details_view.dart';

class BankController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<BankResponse?> bankResponse = Rx<BankResponse?>(null);
  
  // URL for the API
  final String apiUrl = 'https://api.aurify.ae/user/get-banks/67fe1a27a7ef7568048c4cd2';
  final String requestAdminUrl = 'https://api.aurify.ae/request-admin/67fe1a27a7ef7568048c4cd2';
  
  Future<void> fetchBankDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final response = await http.get(Uri.parse(apiUrl), headers: KConstants.headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        bankResponse.value = BankResponse.fromJson(jsonData);
        
        // Check if bank details are empty
        if (bankResponse.value == null || 
            bankResponse.value!.bankInfo.bankDetails.isEmpty) {
          // Bank details are empty, request to admin
          await requestBankDetailsFromAdmin();
          return;
        }
        
        // Navigate to bank details page only if data is available
        Get.to(() => const BankDetailsView(), transition: Transition.cupertino);
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load bank details. Status code: ${response.statusCode}';
        _showErrorSnackbar(errorMessage.value);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error fetching bank details: $e';
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> requestBankDetailsFromAdmin() async {
    try {
      isLoading.value = true;
      
      final requestBody = {
        "request": "Please add bank details for my account. I need this information to proceed with transactions."
      };
      
      final response = await http.post(
        Uri.parse(requestAdminUrl),
        headers: {
          ...KConstants.headers,
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Request Sent',
          'Bank details request has been sent to admin successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50).withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        _showErrorSnackbar('Failed to send request to admin. Please try again later.');
      }
    } catch (e) {
      _showErrorSnackbar('Error sending request: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}