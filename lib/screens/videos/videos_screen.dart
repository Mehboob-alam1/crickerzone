import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> videoList = [
      {
        'title': 'Match Highlights: IND vs AUS',
        'duration': '10:24',
        'thumbnail': 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=500&q=80',
      },
      {
        'title': 'Top 10 Catches of the Week',
        'duration': '05:15',
        'thumbnail': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=500&q=80',
      },
      {
        'title': 'Post-Match Presentation - Babar Azam',
        'duration': '08:45',
        'thumbnail': 'https://images.unsplash.com/photo-1593787406536-3676a152d9cb?w=500&q=80',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('VIDEOS'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          final video = videoList[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: video['thumbnail']!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 40),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video['duration']!,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    video['title']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
