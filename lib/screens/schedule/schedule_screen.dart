import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/match_card.dart';
import '../../widgets/schedule_match_card.dart';
import '../../core/constants/colors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().fetchMatchSchedules('international');
      context.read<MatchProvider>().fetchMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MATCH SCHEDULE'),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'SCHEDULE'),
              Tab(text: 'LIVE'),
              Tab(text: 'UPCOMING'),
              Tab(text: 'RECENT'),
            ],
          ),
        ),
        body: Consumer<MatchProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.matchSchedules.isEmpty && provider.matches.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            return TabBarView(
              children: [
                _buildScheduleList(provider),
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

  Widget _buildScheduleList(MatchProvider provider) {
    final schedules = provider.matchSchedules;
    if (schedules.isEmpty) {
      return _buildEmptyState('No schedules found');
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMatchSchedules('international'),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final daySchedule = schedules[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      daySchedule.date,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              ...daySchedule.seriesSchedules.expand((series) {
                return series.matches.map((match) => ScheduleMatchCard(
                      series: series,
                      match: match,
                    ));
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMatchList(List matches, String emptyMsg) {
    if (matches.isEmpty) {
      return _buildEmptyState(emptyMsg);
    }
    return RefreshIndicator(
      onRefresh: () => context.read<MatchProvider>().fetchMatches(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) => MatchCard(match: matches[index]),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_note, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
