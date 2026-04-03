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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: Colors.red[600],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      match.series.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
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
        CachedNetworkImage(imageUrl: logo, width: 32, height: 32),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(score, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            if (overs != '-' && overs.isNotEmpty)
              Text('($overs)', style: const TextStyle(color: Colors.black45, fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
