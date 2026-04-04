import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> newsList = [
      {
        'title': 'India Clinch Thrilling Victory Against Australia in T20 World Cup',
        'time': '2 hours ago',
        'image': 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=500&q=80',
        'category': 'International',
      },
      {
        'title': 'Babar Azam Reclaims Top Spot in ICC ODI Rankings',
        'time': '5 hours ago',
        'image': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=500&q=80',
        'category': 'Rankings',
      },
      {
        'title': 'Major Injury Blow for England Ahead of Ashes Series',
        'time': '10 hours ago',
        'image': 'https://images.unsplash.com/photo-1593787406536-3676a152d9cb?w=500&q=80',
        'category': 'Breaking',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('LATEST NEWS'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: news['image']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            news['category']!,
                            style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          news['title']!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          news['time']!,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
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
