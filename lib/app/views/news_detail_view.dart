import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../core/models/news_model.dart';
// import '../models/news_model.dart';

class NewsDetailsView extends StatelessWidget {
  final NewsItem newsItem;

  const NewsDetailsView({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        // automaticallyImplyLeading: false,

        previousPageTitle: 'News',
        backgroundColor: CupertinoColors.systemBackground,
        border: const Border(bottom: BorderSide(color: CupertinoColors.separator, width: 0.5)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsItem.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMMM dd, yyyy • hh:mm a').format(newsItem.createdAt),
                  style: const TextStyle(
                    fontSize: 15,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  newsItem.description,
                  style: const TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.label,
                    height: 1.4,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}