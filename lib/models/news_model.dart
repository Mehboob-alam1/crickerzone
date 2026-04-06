class NewsModel {
  final String id;
  final String headline;
  final String intro;
  final String pubTime;
  final String image;
  final String source;
  final String category;

  NewsModel({
    required this.id,
    required this.headline,
    required this.intro,
    required this.pubTime,
    required this.image,
    required this.source,
    required this.category,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      headline: json['headline'] ?? '',
      intro: json['intro'] ?? '',
      pubTime: json['pubTime'] ?? '',
      image: json['imageId'] != null
          ? 'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg'
          : '',
      source: json['source'] ?? 'Cricbuzz',
      category: json['context'] ?? json['category'] ?? 'Cricket',
    );
  }
}
