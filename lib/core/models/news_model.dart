class NewsModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}