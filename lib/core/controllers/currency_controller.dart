import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

import '../constants/price_calculator.dart';
import '../controllers/live_rate_controller.dart';
import '../controllers/live_controller.dart';
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
        _notificationService = notificationService;

  RxDouble originalSpotRate = 0.0.obs;
  RxDouble userDefinedRate = 0.0.obs;
  RxDouble baseRate = 0.0.obs;
  RxList<AlertRate> alertRates = <AlertRate>[].obs;
  RxBool isUserDefinedMode = false.obs;
  RxBool isAddingAlert = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupRateWatchers();
    _fetchExistingAlertRates();

    _notificationService.requestPermissions();
  }

  void _setupRateWatchers() {
    ever<Map<dynamic, dynamic>>(
        _liveRateController.marketData, (_) => _updateRates());

    ever<SpotRateModel?>(_liveController.spotRateModel, (_) => _updateRates());

    _updateRates();
  }

  void _fetchExistingAlertRates() {
    debugPrint(
        'Starting to fetch alert rates from path: ${_alertRatesRef.path}');

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
    userDefinedRate.value += 50.0;
  }

  void decrementRate() {
    isUserDefinedMode.value = true;
    userDefinedRate.value =
        (userDefinedRate.value - 50.0).clamp(0.0, double.infinity);
  }

  void resetToSpotRate() {
    isUserDefinedMode.value = false;
    userDefinedRate.value = originalSpotRate.value;
  }
}

class AlertRate {
  final String id;
  final double rate;

  AlertRate({required this.id, required this.rate});
}
