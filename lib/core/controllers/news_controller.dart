// import 'package:fxg_app/app/core/constants/constants.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../constants/endpoints.dart';
import '../models/news_model.dart';
import 'dart:developer' as developer;

class NewsController extends GetxController {
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _dio.get(
        'https://api.aurify.ae/device/get-news/${KConstants.adminId}',
        options: Options(
          headers: {
            'X-Secret-Key': 'IfiuH/ko+rh/gekRvY4Va0s+aGYuGJEAOkbJbChhcqo=',
          },
        ),
      );

      developer.log('Full News Response: ${response.data}',
          name: 'NewsController');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['success'] == true && responseData['news'] != null) {
          final List<dynamic> newsData = responseData['news']['news'] ?? [];

          developer.log('Parsed News Data: $newsData', name: 'NewsController');

          newsList.value =
              newsData.map((json) => NewsModel.fromJson(json)).toList();

          developer.log('News List Length: ${newsList.length}',
              name: 'NewsController');
        } else {
          errorMessage.value = 'No news available';
        }
      } else {
        errorMessage.value = 'Failed to load news';
      }
    } catch (e) {
      developer.log('Error fetching news: $e', name: 'NewsController');
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void refreshNews() {
    fetchNews();
  }
}