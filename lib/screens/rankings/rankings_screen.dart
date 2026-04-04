import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class RankingsScreen extends StatelessWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ICC RANKINGS'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'TEAMS'),
              Tab(text: 'BATTERS'),
              Tab(text: 'BOWLERS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRankList(['India', 'Australia', 'South Africa', 'Pakistan', 'New Zealand']),
            _buildRankList(['Babar Azam', 'Shubman Gill', 'Virat Kohli', 'Rohit Sharma', 'Harry Brook']),
            _buildRankList(['Josh Hazlewood', 'Rashid Khan', 'Mohammed Siraj', 'Jasprit Bumrah', 'Shaheen Afridi']),
          ],
        ),
      ),
    );
  }

  Widget _buildRankList(List<String> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: 100 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.textPrimary.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Text(
                  '#${index + 1}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  items[index],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.trending_up, color: Colors.green, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
