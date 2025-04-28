import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_color.dart';
import '../../core/models/news_model.dart';

class NewsDetailsView extends StatelessWidget {
  final NewsItem newsItem;

  const NewsDetailsView({super.key, required this.newsItem});

  @override
  Widget build(BuildContext context) {
    // Create new instances of text widgets without decoration
    final title = RichText(
      text: TextSpan(
        text: newsItem.title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          letterSpacing: -0.5,
          decoration: TextDecoration.none, // Explicitly remove decoration
          backgroundColor: Colors.transparent, // Remove any background color
        ),
      ),
    );

    final dateText = Text(
      DateFormat('MMMM dd, yyyy • hh:mm a').format(newsItem.createdAt),
      style: const TextStyle(
        fontSize: 15,
        color: Colors.white70,
        decoration: TextDecoration.none,
      ),
    );

    final description = RichText(
      text: TextSpan(
        text: newsItem.description,
        style: const TextStyle(
          fontSize: 17,
          color: Colors.white,
          height: 1.4,
          letterSpacing: -0.3,
          decoration: TextDecoration.none, // Explicitly remove decoration
          backgroundColor: Colors.transparent, // Remove any background color
        ),
      ),
    );

    return CupertinoPageScaffold(
      backgroundColor: kCaccent,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'News',
        backgroundColor: kCaccent,
        border: const Border(bottom: BorderSide(color: Colors.transparent)),
        leading: const CupertinoNavigationBarBackButton(
          color: Colors.white,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                const SizedBox(height: 8),
                dateText,
                const SizedBox(height: 20),
                description,
              ],
            ),
          ),
        ),
      ),
    );
  }
}