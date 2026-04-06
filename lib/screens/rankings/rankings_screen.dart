import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/ranking_provider.dart';
import '../../models/ranking_model.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  String _currentFormat = 'odi';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RankingProvider>().fetchAllRankings(_currentFormat);
    });
  }

  void _changeFormat(String? format) {
    if (format != null && format != _currentFormat) {
      setState(() {
        _currentFormat = format;
      });
      context.read<RankingProvider>().fetchAllRankings(format);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ICC RANKINGS'),
          actions: [
            DropdownButton<String>(
              value: _currentFormat,
              dropdownColor: AppColors.surface,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'test', child: Text('TEST', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'odi', child: Text('ODI', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 't20', child: Text('T20', style: TextStyle(color: Colors.white))),
              ],
              onChanged: _changeFormat,
            ),
            const SizedBox(width: 16),
          ],
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
        body: Consumer<RankingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                _buildRankList(provider.teamRankings),
                _buildRankList(provider.batterRankings),
                _buildRankList(provider.bowlerRankings),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankList(List<RankingModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return FadeInUp(
          duration: const Duration(milliseconds: 300),
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
                SizedBox(
                  width: 30,
                  child: Text(
                    '${item.rank ?? (index + 1)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? 'Unknown',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.country != null)
                        Text(
                          item.country!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.rating ?? '',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.points != null)
                      Text(
                        '${item.points} pts',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

