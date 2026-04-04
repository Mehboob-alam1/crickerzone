import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class WinPredictionWidget extends StatelessWidget {
  final String teamA;
  final String teamB;
  final int percentageA;
  final int percentageB;

  const WinPredictionWidget({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.percentageA,
    required this.percentageB,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Win Prediction',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                children: [
                  Text(teamA, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  Text('$percentageA%',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: percentageA,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: percentageB,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(teamB, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  Text('$percentageB%',
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
        ],
      ),
    );
  }
}
