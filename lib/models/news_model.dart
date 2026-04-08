import 'package:intl/intl.dart';

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
    String formattedTime = '';
    if (json['pubTime'] != null) {
      try {
        final timestamp = int.tryParse(json['pubTime'].toString());
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          formattedTime = DateFormat('dd MMM yyyy • hh:mm a').format(date);
        }
      } catch (e) {
        formattedTime = json['pubTime'].toString();
      }
    }

    return NewsModel(
      id: json['id']?.toString() ?? '',
      headline: json['hline'] ?? json['headline'] ?? '',
      intro: json['intro'] ?? '',
      pubTime: formattedTime,
      image: json['imageId'] != null
          ? 'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg'
          : '',
      source: json['source'] ?? 'Cricbuzz',
      category: json['context'] ?? json['storyType'] ?? json['category'] ?? 'Cricket',
    );
  }
}
