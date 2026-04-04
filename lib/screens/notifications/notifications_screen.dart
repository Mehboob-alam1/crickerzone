import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'Match Started!',
        'body': 'IND vs AUS T20 World Cup match is now live.',
        'time': '5m ago',
        'type': 'match',
      },
      {
        'title': 'Wicket!',
        'body': 'Jasprit Bumrah takes the wicket of Travis Head.',
        'time': '12m ago',
        'type': 'wicket',
      },
      {
        'title': 'Series Update',
        'body': 'Schedule for India tour of Zimbabwe is now available.',
        'time': '1h ago',
        'type': 'news',
      },
      {
        'title': 'New Video',
        'body': 'Watch the top 10 catches of the week.',
        'time': '3h ago',
        'type': 'video',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATIONS'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return FadeInUp(
                  delay: Duration(milliseconds: 100 * index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.textPrimary.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getIconColor(item['type']!).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(item['type']!),
                            color: _getIconColor(item['type']!),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    item['time']!,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['body']!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
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

  IconData _getIcon(String type) {
    switch (type) {
      case 'match':
        return Icons.sports_cricket;
      case 'wicket':
        return Icons.gavel;
      case 'video':
        return Icons.play_circle_outline;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'match':
        return AppColors.primary;
      case 'wicket':
        return AppColors.secondary;
      case 'video':
        return Colors.blue;
      default:
        return AppColors.accent;
    }
  }
}
