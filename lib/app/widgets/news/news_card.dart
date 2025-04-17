import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/news_model.dart';

class NewsItemWidgetIOS extends StatelessWidget {
  final NewsItem newsItem;
  final VoidCallback onTap;

  const NewsItemWidgetIOS({
    Key? key,
    required this.newsItem,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: CupertinoColors.systemBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItem.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
                letterSpacing: -0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(newsItem.createdAt),
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              newsItem.description,
              style: const TextStyle(
                fontSize: 15,
                color: CupertinoColors.secondaryLabel,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Read more',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: CupertinoColors.activeBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}