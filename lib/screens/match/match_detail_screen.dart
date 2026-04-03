import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../providers/match_provider.dart';
import '../../models/match_model.dart';
import '../../widgets/win_prediction.dart';
import '../../widgets/overs_timeline.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: const [
              SizedBox(width: 8),
              Icon(Icons.arrow_back_ios_new, color: Colors.red, size: 20),
              Text('Back', style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text('IND', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                const Text('213', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('49.1', style: TextStyle(color: Colors.black45, fontSize: 10)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('vs', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            Column(
              children: [
                const Text('SL', style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.bold)),
                const Text('107/6', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('26.4', style: TextStyle(color: Colors.black45, fontSize: 10)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopTabs(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildLiveStatsRow(),
                  _buildStatusMessage(),
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
                  _buildBowlerTable(),
                  _buildOnCreaseSection(),
                  _buildLargeScoreDisplay(),
                  _buildMatchInformation(match),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTab('LIVE', true),
          _buildTab('SCORECARD', false),
          _buildTab('COMMENTARY', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black45,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
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
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Text(
        'Sri Lanka needs 106 run in 138 balls to win',
        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBowlerTable() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Bowler', style: TextStyle(color: Colors.black45, fontSize: 11))),
                Expanded(flex: 2, child: Text('Wkt-Runs', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 11))),
                Expanded(child: Text('Overs', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 11))),
                Expanded(child: Text('Econ', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 11))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('K Yadav', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500))),
                Expanded(flex: 2, child: Text('0-2', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 12))),
                Expanded(child: Text('1.4', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
                Expanded(child: Text('1.71', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 32),
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
          const Text('On Crease - Partnership: 26 (31)', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Batter', style: TextStyle(color: Colors.black45, fontSize: 11))),
                Expanded(flex: 2, child: Text('Run (Ball)', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 11))),
                Expanded(child: Text('4s', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 11))),
                Expanded(child: Text('6s', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 11))),
                Expanded(child: Text('Strike', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 11))),
              ],
            ),
          ),
          _buildBatterRow('D Silva*', '30 (44)', '4', '0', '68.18', isTarget: true),
          _buildBatterRow('D Wellalage', '8 (14)', '0', '0', '57.14'),
          const Divider(height: 32),
        ],
      ),
    );
  }

  Widget _buildBatterRow(String name, String runs, String fours, String sixes, String strike, {bool isTarget = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: TextStyle(color: isTarget ? Colors.red : Colors.black, fontSize: 12, fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(runs, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(child: Text(fours, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 12))),
          Expanded(child: Text(sixes, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 12))),
          Expanded(child: Text(strike, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildLargeScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('At 26.4 Overs', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallTeamLogo('IND', 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313128.logo.png'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('132-4  -  107-6', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              _buildSmallTeamLogo('SL', 'https://img1.hscicdn.com/image/upload/f_auto,t_ds_square_w_160,q_50/lsci/db/PICTURES/CMS/313100/313139.logo.png'),
            ],
          ),
          const Divider(height: 48),
        ],
      ),
    );
  }

  Widget _buildSmallTeamLogo(String name, String logo) {
    return Column(
      children: [
        CachedNetworkImage(imageUrl: logo, width: 32, height: 32),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMatchInformation(MatchModel match) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Match Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 16),
          _buildInfoRow('Toss', 'India, elected to bat first'),
          _buildInfoRow('Series', 'Asia Cup'),
          _buildInfoRow('Season', '2023'),
          _buildInfoRow('Match Number', 'ODI no. 4641'),
          _buildInfoRow('Hours of Days', '15.00 start, First Session\n15.00-18.30, Interval 18.30-19.10,\nSecond Session 19.10-22.40'),
          _buildInfoRow('Match Days', '12 September 2023 - daynight (50-over match)'),
          _buildUmpireRow('Umpires', 'Masudur Rahman', 'Richard Illingworth'),
          _buildInfoRow('TV Umpire', 'Paul Wilson'),
          _buildInfoRow('Reserve Umpire', 'Asif Yaqoob'),
          _buildInfoRow('Match Referee', 'Javagal Srinath'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildUmpireRow(String label, String u1, String u2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUmpireItem(u1),
                const SizedBox(height: 4),
                _buildUmpireItem(u2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUmpireItem(String name) {
    return Row(
      children: [
        Text(name, style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: Colors.blue[400], borderRadius: BorderRadius.circular(4)),
          child: const Text('DRS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
