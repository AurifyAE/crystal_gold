import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../constants/endpoints.dart';
import '../models/news_model.dart';
import 'dart:developer' as developer;

class NewsController extends GetxController {
  final RxList<NewsItem> newsList = <NewsItem>[].obs;
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
        'https://api.aurify.ae/user/get-news/${KConstants.adminId}',
        options: Options(
          headers: {
            'X-Secret-Key': 'IfiuH/ko+rh/gekRvY4Va0s+aGYuGJEAOkbJbChhcqo=',
          },
        ),
      );

      developer.log('News Response Status: ${response.statusCode}',
          name: 'NewsController');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        if (responseData['success'] == true && responseData['news'] != null) {
          // Parse the full response
          final newsResponse = NewsResponse.fromJson(responseData);
          
          // Flatten all news items from all containers into a single list
          final List<NewsItem> allNewsItems = [];
          
          for (var container in newsResponse.news) {
            allNewsItems.addAll(container.newsItems);
          }
          
          // Sort by date (newest first)
          allNewsItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          developer.log('Total News Items: ${allNewsItems.length}', 
              name: 'NewsController');
          
          // Update the observable list
          newsList.value = allNewsItems;
          
          if (allNewsItems.isEmpty) {
            errorMessage.value = 'No news items available';
          }
        } else {
          errorMessage.value = responseData['message'] ?? 'No news available';
        }
      } else {
        errorMessage.value = 'Failed to load news: ${response.statusCode}';
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