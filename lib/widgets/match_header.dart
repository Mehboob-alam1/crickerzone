import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/match_model.dart';
import '../core/constants/colors.dart';
import 'dart:ui';

class MatchHeader extends StatelessWidget {
  final MatchModel match;

  const MatchHeader({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(match.venue, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildHeaderTeam(match.teamA, match.teamALogo, match.scoreA, match.oversA, true)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('VS', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Expanded(child: _buildHeaderTeam(match.teamB, match.teamBLogo, match.scoreB, match.oversB, false)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              match.status,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTeam(String name, String logo, String score, String overs, bool isLeft) {
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        CachedNetworkImage(
          imageUrl: logo,
          width: 48,
          height: 48,
          errorWidget: (context, url, error) => const Icon(Icons.flag, size: 40, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(score == '-' ? 'Yet to bat' : score, 
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16, fontFeatures: [FontFeature.tabularFigures()])),
        if (overs != '-' && overs.isNotEmpty)
          Text('($overs ov)', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}
