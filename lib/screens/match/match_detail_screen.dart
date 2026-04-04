import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../providers/match_provider.dart';
import '../../models/match_model.dart';
import '../../widgets/win_prediction.dart';
import '../../widgets/overs_timeline.dart';
import '../../widgets/batting_score_row.dart';
import '../../widgets/bowling_score_row.dart';
import '../../widgets/venue_weather.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = context.watch<MatchProvider>().matches.firstWhere(
          (m) => m.id == widget.matchId,
          orElse: () => context.read<MatchProvider>().matches.first,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildAppBarTitle(match),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textMuted),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(text: 'LIVE'),
            Tab(text: 'SCORECARD'),
            Tab(text: 'INFO'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveTab(match),
          _buildScorecardTab(match),
          _buildInfoTab(match),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle(MatchModel match) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSmallHeaderScore(match.teamA, match.scoreA, match.oversA),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('vs', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        _buildSmallHeaderScore(match.teamB, match.scoreB, match.oversB),
      ],
    );
  }

  Widget _buildSmallHeaderScore(String team, String score, String overs) {
    return Column(
      children: [
        Text(team, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(score == '-' ? '0' : score,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        if (overs != '-' && overs.isNotEmpty)
          Text(overs, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }

  Widget _buildLiveTab(MatchModel match) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildLiveStatsRow(),
          _buildStatusMessage(match.status),
          const WinPredictionWidget(
            teamA: 'IND',
            teamB: 'SL',
            percentageA: 83,
            percentageB: 17,
          ),
          const OversTimelineWidget(
            currentOver: 'OVER 26.4',
            bowlerName: 'K Yadav',
            balls: ['1', '1', '1', '0'],
            lastOver: 'OVER 25',
            lastBowlerName: 'H Pandya',
          ),
          _buildQuickStats(),
          _buildOnCreaseSection(),
          _buildLargeScoreDisplay(match),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScorecardTab(MatchModel match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTeamHeader(match.teamA, match.scoreA, match.oversA),
        const SizedBox(height: 8),
        const BattingScoreRow(name: 'Rohit Sharma', dismissal: 'c Mendis b Wellalage', runs: '53', balls: '48', fours: '7', sixes: '2', strikeRate: '110.4', isNotOut: false),
        const BattingScoreRow(name: 'Shubman Gill', dismissal: 'b Wellalage', runs: '19', balls: '25', fours: '2', sixes: '0', strikeRate: '76.0', isNotOut: false),
        const BattingScoreRow(name: 'Virat Kohli', dismissal: 'c Shanaka b Wellalage', runs: '3', balls: '12', fours: '0', sixes: '0', strikeRate: '25.0', isNotOut: false),
        const BattingScoreRow(name: 'KL Rahul', dismissal: 'c & b Wellalage', runs: '39', balls: '44', fours: '2', sixes: '0', strikeRate: '88.6', isNotOut: true),
        const Divider(height: 32),
        const BowlingScoreRow(name: 'D Wellalage', overs: '10.0', maidens: '1', runs: '40', wickets: '5'),
        const BowlingScoreRow(name: 'C Asalanka', overs: '9.0', maidens: '0', runs: '18', wickets: '4'),
        const SizedBox(height: 32),
        _buildTeamHeader(match.teamB, match.scoreB, match.oversB),
        const SizedBox(height: 8),
        const BattingScoreRow(name: 'D de Silva', dismissal: 'c Gill b Jadeja', runs: '41', balls: '66', fours: '5', sixes: '0', strikeRate: '62.1', isNotOut: false),
        const BattingScoreRow(name: 'D Wellalage', dismissal: 'not out', runs: '42', balls: '46', fours: '3', sixes: '1', strikeRate: '91.3', isNotOut: true),
      ],
    );
  }

  Widget _buildTeamHeader(String team, String score, String overs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(team, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text('$score ($overs)', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildInfoTab(MatchModel match) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        VenueWeatherWidget(
          venueName: match.venue,
          temp: '28°C',
          humidity: '82%',
          rainChance: '15%',
          updateTime: '10 mins ago',
        ),
        _buildMatchInformation(match),
      ],
    );
  }

  Widget _buildLiveStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('CRR', '4.00'),
          _buildStatItem('RRR', '4.61'),
          _buildStatItem('Target', '214'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatusMessage(String status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        status,
        style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Bowler', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(flex: 2, child: Text('Wkt-Runs', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('Overs', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('Econ', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('K Yadav', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500))),
                Expanded(flex: 2, child: Text('0-2', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                Expanded(child: Text('1.4', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
                Expanded(child: Text('1.71', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 32, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildOnCreaseSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('On Crease - Partnership: 26 (31)', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Batter', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(flex: 2, child: Text('Run (Ball)', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('Strike', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              ],
            ),
          ),
          _buildBatterRow('D Silva*', '30 (44)', '68.18', isTarget: true),
          _buildBatterRow('D Wellalage', '8 (14)', '57.14'),
          const Divider(height: 32, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildBatterRow(String name, String runs, String strike, {bool isTarget = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: TextStyle(color: isTarget ? AppColors.primary : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(runs, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(child: Text(strike, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildLargeScoreDisplay(MatchModel match) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Score Comparison', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallTeamLogo(match.teamA, match.teamALogo),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('${match.scoreA}  -  ${match.scoreB}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
              _buildSmallTeamLogo(match.teamB, match.teamBLogo),
            ],
          ),
          const Divider(height: 48, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildSmallTeamLogo(String name, String logo) {
    return Column(
      children: [
        CachedNetworkImage(imageUrl: logo, width: 32, height: 32, errorWidget: (c,u,e) => const Icon(Icons.flag)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMatchInformation(MatchModel match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Match Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        _buildInfoRow('Series', match.series),
        _buildInfoRow('Venue', match.venue),
        _buildInfoRow('Match Type', 'ODI'),
        _buildInfoRow('Toss', '${match.teamA} won & elected to bat'),
        _buildInfoRow('Time', match.time),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
