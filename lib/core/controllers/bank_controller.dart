// lib/app/modules/bank/controllers/bank_controller.dart

import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../constants/endpoints.dart';
import '../models/bank_model.dart';
// import '../../../data/models/bank_model.dart';

class BankController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<BankResponse?> bankResponse = Rx<BankResponse?>(null);
  
  // URL for the API
  final String apiUrl = 'https://api.aurify.ae/user/get-banks/678fd15ab4011989ef4e57d4';
  
  Future<void> fetchBankDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      final response = await http.get(Uri.parse(apiUrl), headers: KConstants.headers);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        bankResponse.value = BankResponse.fromJson(jsonData);
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load bank details. Status code: ${response.statusCode}';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error fetching bank details: $e';
    } finally {
      isLoading.value = false;
    }
  }
}