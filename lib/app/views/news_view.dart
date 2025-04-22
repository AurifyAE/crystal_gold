import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../core/controllers/news_controller.dart';
import '../widgets/news/news_card.dart';
import 'news_detail_view.dart';

class NewsView extends StatelessWidget {
  final NewsController _newsController = Get.find<NewsController>();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  NewsView({super.key});

  void _onRefresh() async {
    await _newsController.fetchNews();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,

        middle: Text('Breaking News'),
        brightness: Brightness.light,
        backgroundColor: CupertinoColors.systemBackground,
        border: Border(bottom: BorderSide(color: CupertinoColors.separator, width: 0.5)),
      ),
      child: Obx(() {
        if (_newsController.isLoading.value) {
          return const Center(child: CupertinoActivityIndicator());
        }

        if (_newsController.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${_newsController.errorMessage.value}',
                  style: const TextStyle(color: CupertinoColors.destructiveRed),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  onPressed: () => _newsController.refreshNews(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_newsController.newsList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No news available',
                  style: TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton(
                  onPressed: () => _newsController.refreshNews(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          enablePullDown: true,
          header: const ClassicHeader(
            idleText: 'Pull to refresh',
            releaseText: 'Release to refresh',
            refreshingText: 'Loading...',
            completeText: 'Updated',
            failedText: 'Update failed',
            textStyle: TextStyle(color: CupertinoColors.secondaryLabel),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 8),
            itemCount: _newsController.newsList.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              color: CupertinoColors.separator,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final newsItem = _newsController.newsList[index];
              return NewsItemWidgetIOS(
                newsItem: newsItem,
                onTap: () => Get.to(
                  () => NewsDetailsView(newsItem: newsItem),
                  transition: Transition.rightToLeft,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}