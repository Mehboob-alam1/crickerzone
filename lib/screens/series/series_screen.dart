import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> seriesList = [
      {
        'title': 'ICC Men\'s T20 World Cup 2024',
        'date': 'Jun 01 - Jun 29',
        'status': 'Ongoing',
      },
      {
        'title': 'India tour of Zimbabwe, 2024',
        'date': 'Jul 06 - Jul 14',
        'status': 'Upcoming',
      },
      {
        'title': 'England tour of West Indies, 2024',
        'date': 'Oct 31 - Nov 17',
        'status': 'Upcoming',
      },
      {
        'title': 'IPL 2024',
        'date': 'Mar 22 - May 26',
        'status': 'Finished',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRICKET SERIES'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: seriesList.length,
        itemBuilder: (context, index) {
          final series = seriesList[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  series['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    series['date']!,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(series['status']!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(series['status']!).withOpacity(0.5)),
                  ),
                  child: Text(
                    series['status']!,
                    style: TextStyle(
                      color: _getStatusColor(series['status']!),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Ongoing':
        return Colors.green;
      case 'Upcoming':
        return AppColors.primary;
      default:
        return AppColors.textMuted;
    }
  }
}
