import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT US'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ZoomIn(
              child: const Icon(
                Icons.sports_cricket,
                size: 100,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              child: const Text(
                'SCORE ZONE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: const Text(
                'Score Zone is your ultimate companion for live cricket updates. We provide real-time scores, detailed ball-by-ball commentary, player statistics, and the latest news from the world of cricket.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.white10),
            const SizedBox(height: 40),
            _buildInfoTile(Icons.email_outlined, 'Contact Support', 'support@scorezone.com'),
            _buildInfoTile(Icons.language_outlined, 'Official Website', 'www.scorezone.com'),
            _buildInfoTile(Icons.privacy_tip_outlined, 'Privacy Policy', 'Read our terms'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
