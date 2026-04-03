import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../providers/match_provider.dart';
import '../../models/match_model.dart';
import 'dart:ui';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    final match = context.watch<MatchProvider>().matches.firstWhere(
      (m) => m.id == matchId,
      orElse: () => context.read<MatchProvider>().matches.first,
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${match.teamA} vs ${match.teamB}', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(match.series, 
                style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.normal)),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          ],
        ),
        body: Column(
          children: [
            _buildMatchHeader(match),
            Container(
              color: AppColors.surface,
              child: const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                tabs: [
                  Tab(text: 'INFO'),
                  Tab(text: 'LIVE'),
                  Tab(text: 'SCORECARD'),
                  Tab(text: 'SQUADS'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildInfoTab(match),
                  _buildLiveTab(match),
                  _buildScorecardTab(match),
                  _buildSquadsTab(match),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader(MatchModel match) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(match.venue, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildHeaderTeam(match.teamA, match.teamALogo, match.scoreA, match.oversA, true)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('VS', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Expanded(child: _buildHeaderTeam(match.teamB, match.teamBLogo, match.scoreB, match.oversB, false)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              match.status,
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTeam(String name, String logo, String score, String overs, bool isLeft) {
    return Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        CachedNetworkImage(
          imageUrl: logo,
          width: 48,
          height: 48,
          errorWidget: (context, url, error) => const Icon(Icons.flag, size: 40),
        ),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(score == '-' ? 'Yet to bat' : score, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFeatures: [FontFeature.tabularFigures()])),
        if (overs != '-' && overs.isNotEmpty)
          Text('($overs ov)', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }

  Widget _buildInfoTab(MatchModel match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard('Match Details', {
          'Match': '${match.teamA} vs ${match.teamB}, ${match.series}',
          'Date': 'Oct 25, 2024',
          'Time': match.time,
          'Venue': match.venue,
          'Toss': '${match.teamA} won the toss and elected to bat',
        }),
        const SizedBox(height: 16),
        _buildDetailCard('Venue Guide', {
          'Stadium': match.venue,
          'City': 'Dubai',
          'Capacity': '25,000',
          'Ends': 'Emirates End, Paddock End',
        }),
      ],
    );
  }

  Widget _buildLiveTab(MatchModel match) {
    if (match.matchType != 'Live') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_outlined, size: 64, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            const Text('Match starts at 7:30 PM', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        final over = 15 - (index ~/ 6);
        final ball = 6 - (index % 6);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Text('$over.$ball', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Container(width: 1, height: 40, color: Colors.white10),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Shaheen Afridi to Miller, ', style: TextStyle(fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: index % 3 == 0 ? AppColors.primary : Colors.white10, borderRadius: BorderRadius.circular(4)),
                          child: Text(index % 3 == 0 ? '4' : '1', style: TextStyle(color: index % 3 == 0 ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Full length delivery, driven beautifully through the covers for a boundary.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScorecardTab(MatchModel match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBattingScoreTable(match.teamA, match.scoreA, match.oversA),
        const SizedBox(height: 24),
        _buildBowlingScoreTable(match.teamB),
        const SizedBox(height: 32),
        _buildBattingScoreTable(match.teamB, match.scoreB, match.oversB),
        const SizedBox(height: 24),
        _buildBowlingScoreTable(match.teamA),
      ],
    );
  }

  Widget _buildBattingScoreTable(String team, String score, String overs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(team, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
              Text('$score ($overs)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(flex: 4, child: Text('BATTING', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
              Expanded(child: Text('R', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
              Expanded(child: Text('B', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
              Expanded(child: Text('4s', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
              Expanded(child: Text('6s', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        _buildPlayerScoreRow('Babar Azam', 'c Miller b Rabada', '74', '52', '8', '2'),
        _buildPlayerScoreRow('Mohammad Rizwan', 'lbw b Maharaj', '45', '38', '4', '0'),
        _buildPlayerScoreRow('Fakhar Zaman', 'not out', '32', '20', '3', '1'),
        const Divider(color: Colors.white10),
      ],
    );
  }

  Widget _buildBowlingScoreTable(String team) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text('BOWLING ($team)', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(flex: 4, child: SizedBox()),
              Expanded(child: Text('O', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
              Expanded(child: Text('M', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
              Expanded(child: Text('R', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
              Expanded(child: Text('W', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        _buildBowlingRow('Shaheen Afridi', '4.0', '0', '28', '2'),
        _buildBowlingRow('Haris Rauf', '4.0', '0', '35', '1'),
        _buildBowlingRow('Shadab Khan', '4.0', '1', '22', '0'),
      ],
    );
  }

  Widget _buildPlayerScoreRow(String name, String dismissal, String runs, String balls, String fours, String sixes) {
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

  Widget _buildBowlingRow(String name, String overs, String maidens, String runs, String wickets) {
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

  Widget _buildSquadsTab(MatchModel match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSquadList(match.teamA, ['Babar Azam (c)', 'Mohammad Rizwan (wk)', 'Fakhar Zaman', 'Saim Ayub', 'Iftikhar Ahmed', 'Shadab Khan', 'Shaheen Afridi']),
        const SizedBox(height: 24),
        _buildSquadList(match.teamB, ['Aiden Markram (c)', 'Quinton de Kock (wk)', 'David Miller', 'Heinrich Klaasen', 'Kagiso Rabada', 'Keshav Maharaj', 'Lungi Ngidi']),
      ],
    );
  }

  Widget _buildSquadList(String teamName, List<String> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(teamName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        ...players.map((p) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.05), radius: 18, child: const Icon(Icons.person, size: 20, color: AppColors.textMuted)),
          title: Text(p, style: const TextStyle(fontSize: 14)),
          trailing: Text(p.contains('(c)') ? 'Captain' : p.contains('(wk)') ? 'Wicketkeeper' : 'Player', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        )),
      ],
    );
  }

  Widget _buildDetailCard(String title, Map<String, String> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const Divider(height: 24, color: Colors.white10),
          ...details.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 80, child: Text(e.key, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
                Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
