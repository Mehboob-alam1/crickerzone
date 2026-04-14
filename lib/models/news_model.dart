import 'package:intl/intl.dart';

class NewsModel {
  final String id;
  final String headline;
  final String intro;
  final String pubTime;
  final String image;
  final String source;
  final String category;
  final String storyType;

  NewsModel({
    required this.id,
    required this.headline,
    required this.intro,
    required this.pubTime,
    required this.image,
    required this.source,
    required this.category,
    this.storyType = '',
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    String formattedTime = '';
    final rawTime = json['pubTime'] ?? json['publishTime'];
    if (rawTime != null) {
      try {
        final timestamp = int.tryParse(rawTime.toString());
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          formattedTime = DateFormat('dd MMM yyyy • hh:mm a', 'en_US').format(date);
        }
      } catch (e) {
        formattedTime = rawTime.toString();
      }
    }

    final cover = json['coverImage'];
    String imageUrl = '';
    if (json['imageId'] != null) {
      imageUrl =
          'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg';
    } else if (cover is Map && cover['id'] != null) {
      imageUrl =
          'https://static.cricbuzz.com/a/img/v1/i1/c${cover['id']}/i.jpg';
    }

    final type = json['storyType']?.toString() ?? '';
    final ctx = json['context']?.toString() ?? '';
    final catLabel = ctx.isNotEmpty ? ctx : (type.isNotEmpty ? type : 'Cricket');

    return NewsModel(
      id: json['id']?.toString() ?? '',
      headline: json['hline']?.toString() ?? json['headline']?.toString() ?? '',
      intro: json['intro']?.toString() ?? '',
      pubTime: formattedTime,
      image: imageUrl,
      source: json['source']?.toString() ?? 'Cricbuzz',
      category: catLabel,
      storyType: type,
    );
  }
}
