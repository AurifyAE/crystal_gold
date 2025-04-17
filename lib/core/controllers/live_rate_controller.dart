import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// import '../core/constant/constants.dart';
// import '../core/constants/constants.dart';
import '../constants/endpoints.dart';
import '../models/commodity_model.dart';
import '../models/server_details_model.dart';
import '../models/live_rate_model.dart';

class LiveRateController extends GetxController {
  IO.Socket? _socket;
  final Rx<LiveRateModel?> liveRateModel = Rx<LiveRateModel?>(null);
  final RxMap marketData = {}.obs;
  final RxString serverLink = 'https://capital-server-gnsu.onrender.com'.obs;
  final RxBool isServerLinkLoaded = false.obs;
  final RxBool isConnected = false.obs;
  final RxBool isAlertShown = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializeConnection();
  }

  Future<void> initializeConnection() async {
    try {
      final link = await fetchServerLink();
      if (link.isNotEmpty) {
        serverLink.value = link;
        isServerLinkLoaded.value = true;
      }
      await initializeSocketConnection(link: serverLink.value);
      log('Connection initialized successfully');
    } catch (e) {
      log("Error initializing connection: $e");
      await initializeSocketConnection(link: serverLink.value);
    }
  }

  Future<List<String>> fetchCommodityArray() async {
    try {
      const id = "IfiuH/ko+rh/gekRvY4Va0s+aGYuGJEAOkbJbChhcqo=";
      final response = await http.get(
        Uri.parse('${KConstants.baseUrl}get-commodities/${KConstants.adminId}'),
        headers: {
          'X-Secret-Key': id,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final commodity = CommodityModel.fromMap(json.decode(response.body));
        log('Commodities fetched successfully');
        return commodity.commodities;
      } else {
        log("Failed to fetch commodity array: ${response.statusCode}");
        return ["Gold", "Silver"];
      }
    } catch (e) {
      log("Error fetching commodity array: $e");
      return ["Gold", "Silver"];
    }
  }

  Future<String> fetchServerLink() async {
    try {
      final response = await http.get(
        Uri.parse('${KConstants.baseUrl}get-server'),
        headers: {
          'X-Secret-Key': KConstants.secretKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final serverDetails = ServerModel.fromMap(json.decode(response.body));
        log('Server URL fetched successfully');
        return serverDetails.info.serverUrl;
      } else {
        log("Failed to load server link: ${response.statusCode}");
        return serverLink.value;
      }
    } catch (e) {
      log("Error fetching server link: $e");
      return serverLink.value;
    }
  }

  Future<void> initializeSocketConnection({required String link}) async {
    try {
      _socket = IO.io(link, {
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
        'reconnection': true,
        'query': {'secret': 'aurify@123'},
      });

      _socket?.onConnect((_) async {
        log('Connected to WebSocket server');
        isConnected.value = true;
        isAlertShown.value = false;

        try {
          List<String> commodityArray = await fetchCommodityArray();
          _requestMarketData(commodityArray);
          log('Server initialized');
        } catch (e) {
          log("Error fetching commodity array: $e");
          _requestMarketData(["Gold", "Silver"]);
        }
      });

      _socket?.on('market-data', (data) {
        _handleMarketData(data);
      });

      _socket?.onConnectError((data) {
        log('Connection Error: $data');
        isConnected.value = false;
      });

      _socket?.onDisconnect((_) {
        log('Disconnected from WebSocket server');
        isConnected.value = false;

        _attemptReconnection();
      });

      _socket?.connect();
    } catch (e) {
      log("Socket connection error: $e");
      _attemptReconnection();
    }
  }

  void _handleMarketData(dynamic data) {
    try {
      if (data is Map<String, dynamic> && data['symbol'] is String) {
        Map<String, dynamic> processedData = Map<String, dynamic>.from(data);

        processedData.forEach((key, value) {
          if (value is num && value is! double) {
            processedData[key] = value.toDouble();
          }
        });

        marketData[processedData['symbol']] = processedData;

        if (processedData['bid'] == 0.0) {
          _showMaintenanceAlert();
        }

        try {
          liveRateModel.value = LiveRateModel.fromJson(marketData);

          _checkBidsAndShowAlert();
        } catch (e) {
          log("❌ Error parsing market data to model: $e");
        }
      } else {
        log("❗ Invalid market data format: ${jsonEncode(data)}");
      }
    } catch (e) {
      log("❌ Exception in handling market data: $e");
    }
  }

  void _checkBidsAndShowAlert() {
    if (liveRateModel.value != null) {
      bool goldBidZero = liveRateModel.value!.gold?.bid == 0.0;
      bool silverBidZero = liveRateModel.value!.silver?.bid == 0.0;

      if (goldBidZero || silverBidZero) {
        _showMaintenanceAlert();
      }
    }
  }

  void _showMaintenanceAlert() {
    if (!isAlertShown.value && Get.context != null) {
      isAlertShown.value = true;

      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.purple[800],
                size: 50,
              ),
              const SizedBox(height: 10),
              const Text(
                'Server Under Maintenance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            'We are currently experiencing technical issues. Our team is working to resolve this as soon as possible. Please try again later.',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Get.back();
                  reconnect();
                },
                child: const Text(
                  'Retry Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  void _requestMarketData(List<String> symbols) {
    try {
      _socket?.emit('request-data', [symbols]);
    } catch (e) {
      log("Error requesting market data: $e");
    }
  }

  void _attemptReconnection() {
    if (!isConnected.value) {
      log("Attempting to reconnect in 5 seconds...");
      Future.delayed(Duration(seconds: 5), () {
        initializeConnection();
      });
    }
  }

  void reconnect() {
    try {
      _socket?.disconnect();
      isAlertShown.value = false;
      initializeConnection();
    } catch (e) {
      log("Error reconnecting: $e");
    }
  }

  @override
  void onClose() {
    _socket?.disconnect();
    super.onClose();
  }
}
