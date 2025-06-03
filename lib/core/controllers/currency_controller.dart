import 'dart:async';
import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../constants/price_calculator.dart';
import '../constants/price_calculator.dart';
import '../controllers/live_rate_controller.dart';
import '../controllers/live_controller.dart';
// import '../core/utils/price_calculator.dart';
// import '../core/utils/price_calculator.dart';
import '../models/spot_rate_model.dart';
import '../repositories/notification_service.dart';

class CurrencyController extends GetxController {
  final LiveRateController _liveRateController;
  final LiveController _liveController;
  final DatabaseReference _alertRatesRef;
  final NotificationService _notificationService;

  CurrencyController({
    required LiveRateController liveRateController,
    required LiveController liveController,
    required DatabaseReference alertRatesRef,
    required NotificationService notificationService,
  })  : _liveRateController = liveRateController,
        _liveController = liveController,
        _alertRatesRef = alertRatesRef,
        _notificationService = notificationService {
    debugPrint('CurrencyController initialized with alertRatesRef: ${_alertRatesRef.path}');
  }

  RxDouble originalSpotRate = 0.0.obs;
  RxDouble userDefinedRate = 0.0.obs;
  RxDouble baseRate = 0.0.obs;
  RxList<AlertRate> alertRates = <AlertRate>[].obs;
  RxBool isUserDefinedMode = false.obs;
  RxBool isAddingAlert = false.obs;
  // Add a new RxDouble for the increment/decrement value
  RxDouble incrementValue = 0.5.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('CurrencyController onInit called');
    _setupRateWatchers();
    _fetchExistingAlertRates();
    _loadSavedIncrementValue();

    _notificationService.requestPermissions();
  }

  // Load saved increment value from SharedPreferences
  Future<void> _loadSavedIncrementValue() async {
    try {
      debugPrint('Loading saved increment value');
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getDouble('increment_value');
      if (savedValue != null) {
        incrementValue.value = savedValue;
        debugPrint('Loaded saved increment value: ${incrementValue.value}');
      } else {
        debugPrint('No saved increment value found, using default: ${incrementValue.value}');  
      }
    } catch (e) {
      debugPrint('Error loading saved increment value: $e');
    }
  }

  // Save increment value to SharedPreferences
  Future<void> saveIncrementValue(double value) async {
    try {
      debugPrint('Saving increment value: $value');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('increment_value', value);
      incrementValue.value = value;
      debugPrint('Saved increment value: $value');
      Get.snackbar('Success', 'Increment value updated to ${value.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('Error saving increment value: $e');
      Get.snackbar('Error', 'Failed to save increment value: ${e.toString()}');
    }
  }

  void _setupRateWatchers() {
    debugPrint('Setting up rate watchers');
    ever<Map<dynamic, dynamic>>(
        _liveRateController.marketData, (_) => _updateRates());

    ever<SpotRateModel?>(_liveController.spotRateModel, (_) => _updateRates());

    _updateRates();
  }

  void _fetchExistingAlertRates() {
    debugPrint('Starting to fetch alert rates from path: ${_alertRatesRef.path}');

    _alertRatesRef.onValue.listen((event) {
      debugPrint('Received data from Firebase: ${event.snapshot.value}');
      final dynamic data = event.snapshot.value;

      if (data != null) {
        if (data is Map) {
          try {
            alertRates.value = data.entries.map<AlertRate>((entry) {
              debugPrint('Processing entry: ${entry.key} = ${entry.value}');
              return AlertRate(
                  id: entry.key, rate: double.parse(entry.value.toString()));
            }).toList();
            debugPrint('Successfully parsed ${alertRates.length} alert rates');
          } catch (e) {
            debugPrint('Error parsing alert rates: $e');
            alertRates.value = [];
            Get.snackbar(
                'Error', 'Failed to parse alert rates: ${e.toString()}');
          }
        } else {
          debugPrint('Data is not a map: ${data.runtimeType}');
          alertRates.value = [];
        }
      } else {
        debugPrint('No alert rates found in Firebase');
        alertRates.value = [];
      }
    }, onError: (error) {
      debugPrint('Error fetching alert rates: $error');
      Get.snackbar('Error', 'Failed to load alert rates: ${error.toString()}');
    });
  }

  void _updateRates() {
    debugPrint('Updating rates from live data');
    final marketData = _liveRateController.marketData['Gold'];
    final spotRateModel = _liveController.spotRateModel.value;

    if (marketData != null && spotRateModel != null) {
      final priceModel = PriceCalculator.calculatePrices(
        commodityName: 'Gold',
        marketData: marketData,
        spotRateModel: spotRateModel,
        isLoading: false,
      );

      if (!isUserDefinedMode.value) {
        originalSpotRate.value = priceModel.bidPrice;
        userDefinedRate.value = originalSpotRate.value;
      }

      baseRate.value = priceModel.lowPrice;

      _checkAlertRates(originalSpotRate.value);
    }
  }

  void _checkAlertRates(double currentRate) {
    for (var alertRate in alertRates) {
      if (_isRateTriggered(currentRate, alertRate.rate)) {
        debugPrint('Alert triggered for rate: ${alertRate.rate}');
        _notificationService.showNotification(
            title: 'Gold Rate Alert',
            body:
                'Current rate (${currentRate.toStringAsFixed(2)}) has reached your alert rate of ${alertRate.rate.toStringAsFixed(2)}');
      }
    }
  }

  bool _isRateTriggered(double currentRate, double alertRate) {
    return (currentRate >= alertRate);
  }

  Future<void> addAlertRate() async {
    if (isAddingAlert.value) return;

    if (userDefinedRate.value <= 0) {
      Get.snackbar('Error', 'Alert rate must be greater than zero');
      return;
    }

    if (alertRates.any((alert) => alert.rate == userDefinedRate.value)) {
      Get.snackbar('Error', 'This alert rate already exists');
      return;
    }

    try {
      isAddingAlert.value = true;

      debugPrint(
          'Attempting to write alert rate: ${userDefinedRate.value.toStringAsFixed(2)}');

      final newAlertRateRef = _alertRatesRef.push();

      await newAlertRateRef
          .set(userDefinedRate.value.toStringAsFixed(2))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'Firebase write timed out. Check your connection.');
      });

      debugPrint(
          'Alert rate written successfully with key: ${newAlertRateRef.key}');
      Get.snackbar('Success',
          'Alert set successfully at ${userDefinedRate.value.toStringAsFixed(2)}');
    } catch (e) {
      debugPrint('Error adding alert rate: $e');

      String errorMessage = 'Failed to add alert rate';

      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Permission denied. Check your Firebase database rules.';
      } else if (e.toString().contains('NETWORK_ERROR')) {
        errorMessage = 'Network error. Check your internet connection.';
      } else if (e is TimeoutException) {
        errorMessage = 'Operation timed out. Check your internet connection.';
      }

      Get.snackbar('Error', '$errorMessage: ${e.toString()}');
    } finally {
      isAddingAlert.value = false;
    }
  }

  Future<void> removeAlertRate(AlertRate alertRate) async {
    try {
      await _alertRatesRef.child(alertRate.id).remove();
      Get.snackbar('Success', 'Alert removed successfully');
    } catch (e) {
      debugPrint('Error removing alert rate: $e');
      Get.snackbar('Error', 'Failed to remove alert rate: ${e.toString()}');
    }
  }

  void incrementRate() {
    isUserDefinedMode.value = true;
    userDefinedRate.value += incrementValue.value;
    debugPrint('Incremented rate to: ${userDefinedRate.value}');
  }

  void decrementRate() {
    isUserDefinedMode.value = true;
    userDefinedRate.value =
        (userDefinedRate.value - incrementValue.value).clamp(0.0, double.infinity);
    debugPrint('Decremented rate to: ${userDefinedRate.value}');
  }

  void resetToSpotRate() {
    isUserDefinedMode.value = false;
    userDefinedRate.value = originalSpotRate.value;
    debugPrint('Reset to spot rate: ${userDefinedRate.value}');
  }
  
  // Show increment value adjustment dialog
  void showIncrementAdjustDialog() {
    final RxDouble tempValue = incrementValue.value.obs;
    
    debugPrint('Showing increment adjustment dialog, current value: ${incrementValue.value}');
    
    double lastHapticValue = tempValue.value; // keeps track of last haptic step

Get.dialog(
  CupertinoAlertDialog(
    title: const Text('Adjust Increment Value'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Obx(() => Text(
              '${tempValue.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            )),
        const SizedBox(height: 20), 
        Obx(() => CupertinoSlider(
              value: tempValue.value,
              min: 0.1, 
              max: 0.5,
              divisions: 8, // 0.05 steps
              onChanged: (value) {
                final roundedValue = double.parse(value.toStringAsFixed(2));
                if (roundedValue != lastHapticValue) {
                  lastHapticValue = roundedValue;
                  if (Platform.isAndroid || Platform.isIOS) {
                    HapticFeedback.selectionClick();
                  }
                }
                tempValue.value = roundedValue;
              },
            )),
      ],
    ),
    actions: [
      CupertinoDialogAction(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          saveIncrementValue(tempValue.value);
          Get.back();
        },
        child: const Text('Save'),
      ),
    ],
  ),
);
  }
  
  // New method to show edit rate dialog
  void showEditRateDialog() {
    final TextEditingController textController = TextEditingController(
      text: userDefinedRate.value.toStringAsFixed(2),
    );
    
    debugPrint('Showing edit rate dialog, current value: ${userDefinedRate.value}');
    
    Get.dialog(
      AlertDialog(
        
        title: const Text('Set Custom Rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your custom alert rate'),
            const SizedBox(height: 20),
            TextField(
              controller: textController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Rate',
                border: OutlineInputBorder(),
                suffixText: 'USD',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              try {
                final newRate = double.parse(textController.text);
                if (newRate > 0) {
                  userDefinedRate.value = newRate;
                  isUserDefinedMode.value = true;
                  debugPrint('Custom rate set to: $newRate');
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Rate must be greater than zero');
                }
              } catch (e) {
                Get.snackbar('Error', 'Please enter a valid number');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class AlertRate {
  final String id;
  final double rate;

  AlertRate({required this.id, required this.rate});
}