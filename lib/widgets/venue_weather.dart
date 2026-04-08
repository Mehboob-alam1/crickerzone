import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

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
          const Text('Venue & Weather',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venueName,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.wb_sunny_rounded, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Text(temp,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildWeatherDetail(Icons.water_drop_outlined, 'Humidity: $humidity'),
                        const SizedBox(height: 4),
                        _buildWeatherDetail(Icons.cloud_outlined, 'Rain: $rainChance'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Updated: $updateTime',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
