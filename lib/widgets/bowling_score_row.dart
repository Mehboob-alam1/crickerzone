import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class BowlingScoreRow extends StatelessWidget {
  final String name;
  final String overs;
  final String maidens;
  final String runs;
  final String wickets;

  const BowlingScoreRow({
    super.key,
    required this.name,
    required this.overs,
    required this.maidens,
    required this.runs,
    required this.wickets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          Expanded(child: Text(overs, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(maidens, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(runs, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))),
          Expanded(child: Text(wickets, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary))),
        ],
      ),
    );
  }
}
