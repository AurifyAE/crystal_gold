// Updated News Models
class NewsResponse {
  final bool success;
  final List<NewsContainer> news;
  final String message;

  NewsResponse({
    required this.success,
    required this.news,
    required this.message,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      success: json['success'] ?? false,
      news: json['news'] != null
          ? (json['news'] as List).map((item) => NewsContainer.fromJson(item)).toList()
          : [],
      message: json['message'] ?? '',
    );
  }
}

class NewsContainer {
  final String id;
  final List<NewsItem> newsItems;
  final dynamic createdBy;
  final bool isAutomated;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsContainer({
    required this.id,
    required this.newsItems,
    required this.createdBy,
    required this.isAutomated,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsContainer.fromJson(Map<String, dynamic> json) {
    return NewsContainer(
      id: json['_id'] ?? '',
      newsItems: json['news'] != null
          ? (json['news'] as List).map((item) => NewsItem.fromJson(item)).toList()
          : [],
      createdBy: json['createdBy'],
      isAutomated: json['isAutomated'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class NewsItem {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}




// class NewsModel {
//   final String id;
//   final String title;
//   final String description;
//   final DateTime createdAt;

//   NewsModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.createdAt,
//   });

//   factory NewsModel.fromJson(Map<String, dynamic> json) {
//     return NewsModel(
//       id: json['_id'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
//     );
//   }
// }