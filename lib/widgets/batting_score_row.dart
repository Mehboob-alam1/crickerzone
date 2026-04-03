import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class BattingScoreRow extends StatelessWidget {
  final String name;
  final String dismissal;
  final String runs;
  final String balls;
  final String fours;
  final String sixes;

  const BattingScoreRow({
    super.key,
    required this.name,
    required this.dismissal,
    required this.runs,
    required this.balls,
    required this.fours,
    required this.sixes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                Text(dismissal, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          Expanded(child: Text(runs, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(balls, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          Expanded(child: Text(fours, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          Expanded(child: Text(sixes, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
        ],
      ),
    );
  }
}
