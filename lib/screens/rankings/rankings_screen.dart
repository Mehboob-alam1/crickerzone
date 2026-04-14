import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  Future<void> _refreshRankings() {
    return context.read<RankingProvider>().fetchAllRankings(_currentFormat, forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
            isScrollable: true,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'TEAMS'),
              Tab(text: 'BATTERS'),
              Tab(text: 'BOWLERS'),
              Tab(text: 'WTC'),
            ],
          ),
        ),
        body: Consumer<RankingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return RefreshIndicator(
                onRefresh: _refreshRankings,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
              );
            }
            return TabBarView(
              children: [
                _buildRankList(provider.teamRankings, _refreshRankings),
                _buildRankList(provider.batterRankings, _refreshRankings),
                _buildRankList(provider.bowlerRankings, _refreshRankings),
                _buildWtcStandings(provider.iccStandings, _refreshRankings),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankList(List<RankingModel> items, Future<void> Function() onRefresh) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 320,
              child: Center(
                child: Text('No data available', style: TextStyle(color: AppColors.textMuted)),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
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
              border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.05)),
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
      ),
    );
  }

  Widget _buildWtcStandings(Map<String, dynamic>? data, Future<void> Function() onRefresh) {
    if (data == null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 280,
              child: Center(
                child: Text(
                  'WTC standings unavailable',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final headers =
        (data['headers'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final rows = (data['values'] as List?) ?? [];
    final subText = data['subText']?.toString() ?? '';

    if (headers.isEmpty || rows.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 280,
              child: Center(
                child: Text(
                  'No WTC data',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(color: AppColors.surface),
                children: headers
                    .map(
                      (h) => Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          h,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              ...rows.map((row) {
                final cells = (row is Map && row['value'] is List)
                    ? (row['value'] as List).map((e) => e.toString()).toList()
                    : <String>[];
                return TableRow(
                  children: cells.asMap().entries.map((entry) {
                    final i = entry.key;
                    final v = entry.value;
                    final isLikelyImageId = i == 1 && int.tryParse(v) != null;
                    if (isLikelyImageId) {
                      return Padding(
                        padding: const EdgeInsets.all(6),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://static.cricbuzz.com/a/img/v1/i1/c$v/i.jpg',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const SizedBox(
                            width: 32,
                            height: 32,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        v,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
        if (subText.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            subText,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ],
    ),
    );
  }
}

