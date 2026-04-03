import 'package:flutter/material.dart';

class VenueWeatherWidget extends StatelessWidget {
  final String venueName;
  final String temp;
  final String humidity;
  final String rainChance;
  final String updateTime;

  const VenueWeatherWidget({
    super.key,
    required this.venueName,
    required this.temp,
    required this.humidity,
    required this.rainChance,
    required this.updateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(venueName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.wb_cloudy_outlined, color: Colors.yellow[700], size: 40),
              const SizedBox(width: 12),
              Text(temp, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('updated at $updateTime', style: const TextStyle(color: Colors.black45, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWeatherDetail(Icons.water_drop_outlined, '$humidity Humidity'),
              const SizedBox(width: 40),
              _buildWeatherDetail(Icons.cloud_outlined, '$rainChance Chance'),
            ],
          ),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }
}
