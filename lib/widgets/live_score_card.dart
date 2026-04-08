import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../core/constants/colors.dart';

class LiveScoreCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onTap;

  const LiveScoreCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.secondary.withValues(alpha: 0.15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      match.series.toUpperCase(),
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('LIVE', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTeamRow(match.teamA, match.teamALogo, match.scoreA, match.oversA),
                    const SizedBox(height: 12),
                    _buildTeamRow(match.teamB, match.teamBLogo, match.scoreB, match.oversB),
                    const Divider(height: 24),
                    Text(
                      match.status,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(String name, String logo, String score, String overs) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: logo.isEmpty
              ? Container(
                  width: 32,
                  height: 32,
                  color: Colors.white12,
                  child: const Icon(Icons.flag, size: 20, color: AppColors.textMuted),
                )
              : CachedNetworkImage(
                  imageUrl: logo,
                  width: 32,
                  height: 32,
                  placeholder: (context, url) => Container(color: Colors.white12),
                  errorWidget: (context, url, error) => const Icon(Icons.flag, size: 24, color: AppColors.textMuted),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(score == '-' ? '' : score, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
            if (overs != '-' && overs.isNotEmpty)
              Text('($overs)', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
