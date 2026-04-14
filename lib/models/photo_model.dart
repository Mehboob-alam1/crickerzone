import 'package:intl/intl.dart';

class PhotoModel {
  final String id;
  final String headline;
  final String image;
  final String time;

  PhotoModel({
    required this.id,
    required this.headline,
    required this.image,
    required this.time,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    String formattedTime = '';
    if (json['publishedTime'] != null) {
      try {
        final timestamp = int.tryParse(json['publishedTime'].toString());
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          formattedTime = DateFormat('dd MMM yyyy', 'en_US').format(date);
        }
      } catch (e) {
        formattedTime = json['publishedTime'].toString();
      }
    }

    return PhotoModel(
      id: json['galleryId']?.toString() ?? '',
      headline: json['headline'] ?? '',
      image: json['imageId'] != null
          ? 'https://static.cricbuzz.com/a/img/v1/i1/c${json['imageId']}/i.jpg'
          : '',
      time: formattedTime,
    );
  }
}
