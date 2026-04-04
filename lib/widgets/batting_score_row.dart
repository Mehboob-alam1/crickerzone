import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class BattingScoreRow extends StatelessWidget {
  final String name;
  final String dismissal;
  final String runs;
  final String balls;
  final String fours;
  final String sixes;
  final String strikeRate;
  final bool isNotOut;

  const BattingScoreRow({
    super.key,
    required this.name,
    required this.dismissal,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
    required this.strikeRate,
    this.isNotOut = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name + (isNotOut ? '*' : ''),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isNotOut ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  dismissal,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildCell(runs, isBold: true),
          _buildCell(balls, isMuted: true),
          _buildCell(fours, isMuted: true),
          _buildCell(sixes, isMuted: true),
          _buildCell(strikeRate, isMuted: true),
        ],
      ),
    );
  }

  Widget _buildCell(String text, {bool isBold = false, bool isMuted = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: isBold ? 13 : 12,
          color: isMuted ? AppColors.textMuted : AppColors.textPrimary,
        ),
      ),
    );
  }
}
