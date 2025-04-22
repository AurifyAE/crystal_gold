import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get/get.dart';


import '../constants/endpoints.dart';
import '../constants/failure.dart';
import '../constants/type_def.dart';
import '../models/spot_rate_model.dart';

class LiveRepository extends GetxService {
FutureEither<SpotRateModel> getSpotRate() async {
  try {
    final response = await Dio().get(
      "${KConstants.baseUrl}/get-spotrates/${KConstants.adminId}",
      options: Options(headers: KConstants.headers, method: "GET"),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = response.data;
      log('Spot rate data received: $data');

      // Debug: Print out the types of numeric fields
      if (data.containsKey('info') && data['info'] is Map) {
        Map<String, dynamic> info = data['info'];
        info.forEach((key, value) {
          if (key.contains('Spread') || key.contains('Margin')) {
            log('Key: $key, Value: $value, Type: ${value.runtimeType}');
          }
        });
      }

      try {
        final spotRateModel = SpotRateModel.fromMap(data);
        return right(spotRateModel);
      } catch (parseError) {
        log('Error parsing spot rate data: $parseError');
        log('Data causing error: $data');
        return left(Failure("Error parsing spot rate data: $parseError"));
      }
    } else {
      return left(Failure("HTTP Error: ${response.statusCode}"));
    }
  } on DioException catch (e) {
    log('Dio Error details:');
    log('Error: ${e.error}');
    log('Message: ${e.message}');
    log('Response: ${e.response}');
    return left(Failure("Network Error: ${e.message}"));
  } catch (e) {
    log('Unexpected error: $e');
    return left(Failure(e.toString()));
  }
}
}
