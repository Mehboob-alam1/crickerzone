import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../core/constants/colors.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final bool isLive;

  const MatchCard({super.key, required this.match, this.isLive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLive ? 320 : double.infinity,
      // For live matches in a horizontal list, we set a fixed height to ensure uniformity
      // and allow the use of Spacer() inside the Column.
      height: isLive ? 220 : null,
      margin: EdgeInsets.only(
        right: isLive ? 12 : 0,
        bottom: isLive ? 0 : 12,
      ),
      child: InkWell(
        onTap: () => context.push('/match/${match.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Card(
          elevation: 0,
          color: AppColors.surface,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isLive ? AppColors.primary.withOpacity(0.2) : AppColors.textPrimary.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              // In horizontal list (isLive), we want the Column to fill the card height
              mainAxisSize: isLive ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        match.series.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTeamRow(match.teamA, match.teamALogo, match.scoreA, match.oversA),
                const SizedBox(height: 12),
                _buildTeamRow(match.teamB, match.teamBLogo, match.scoreB, match.oversB),
                
                // Use Spacer for live matches to push the status to the bottom
                // In vertical lists, we use fixed spacing to avoid layout errors
                if (isLive) const Spacer() else const SizedBox(height: 16),

                const Divider(height: 1, color: Colors.white10),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.status,
                        style: TextStyle(
                          color: isLive ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: isLive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamRow(String name, String logoUrl, String score, String overs) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(width: 32, height: 32, color: Colors.white10),
            errorWidget: (context, url, error) => const Icon(Icons.flag, size: 24, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              score == '-' ? '' : score,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (overs != '-' && overs.isNotEmpty)
              Text(
                '($overs)',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
          ],
        ),
      ],
    );
  }
}
