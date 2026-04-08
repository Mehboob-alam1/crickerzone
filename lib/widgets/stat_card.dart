import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
