import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/player_model.dart';
import '../core/constants/colors.dart';
import '../screens/player/player_profile_screen.dart';

class PlayerCard extends StatelessWidget {
  final PlayerModel player;
  final int index;

  const PlayerCard({
    super.key,
    required this.player,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: player.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.surface),
                errorWidget: (context, url, error) => const Icon(Icons.person, color: AppColors.textMuted),
              ),
            ),
          ),
          title: Text(
            player.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.role,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildMiniStat('Runs', player.runs),
                  const SizedBox(width: 12),
                  _buildMiniStat('Avg', player.average),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerProfileScreen(playerId: player.id),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
