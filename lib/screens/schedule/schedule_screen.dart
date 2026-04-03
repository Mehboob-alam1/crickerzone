import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/match_card.dart';
import '../../core/constants/colors.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MATCH SCHEDULE'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'LIVE'),
              Tab(text: 'UPCOMING'),
              Tab(text: 'RECENT'),
            ],
          ),
        ),
        body: Consumer<MatchProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildMatchList(provider.liveMatches, 'No live matches right now'),
                _buildMatchList(provider.upcomingMatches, 'No upcoming matches scheduled'),
                _buildMatchList(provider.recentMatches, 'No recent matches found'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMatchList(List matches, String emptyMsg) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_note, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            Text(emptyMsg, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) => MatchCard(match: matches[index]),
    );
  }
}
