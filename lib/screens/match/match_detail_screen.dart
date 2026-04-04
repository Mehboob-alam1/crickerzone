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
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    final match = matchProvider.matches.firstWhere(
      (m) => m.id == widget.matchId,
      orElse: () => matchProvider.matches.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const SizedBox(width: 8),
              const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
              FadeInLeft(
                child: const Text('Back', style: TextStyle(color: AppColors.primary, fontSize: 16)),
              ),
            ],
          ),
        ),
        title: FadeInDown(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(match.teamA, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(match.scoreA, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(match.oversA, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('vs', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Column(
                children: [
                  Text(match.teamB, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(match.scoreB == '-' ? '0/0' : match.scoreB, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(match.oversB == '-' ? '0.0' : match.oversB, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTopTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiveView(match),
                _buildScorecardView(match),
                _buildCommentaryView(),
                _buildSquadsView(match),
                _buildInfoView(match),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTabs() {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'LIVE'),
          Tab(text: 'SCORECARD'),
          Tab(text: 'COMMENTARY'),
          Tab(text: 'SQUADS'),
          Tab(text: 'INFO'),
        ],
      ),
    );
  }

  Widget _buildLiveView(MatchModel match) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          FadeInDown(child: _buildLiveStatsRow()),
          FadeInDown(delay: const Duration(milliseconds: 100), child: _buildStatusMessage(match)),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: WinPredictionWidget(
              teamA: match.teamA,
              teamB: match.teamB,
              percentageA: 83,
              percentageB: 17,
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: const OversTimelineWidget(
              currentOver: 'OVER 26.4',
              bowlerName: 'K Yadav',
              balls: ['1', '1', '1', '0'],
              lastOver: 'OVER 25',
              lastBowlerName: 'H Pandya',
            ),
          ),
          FadeInUp(delay: const Duration(milliseconds: 400), child: _buildBowlerTable()),
          FadeInUp(delay: const Duration(milliseconds: 500), child: _buildOnCreaseSection()),
          FadeInUp(delay: const Duration(milliseconds: 600), child: _buildLargeScoreDisplay(match)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScorecardView(MatchModel match) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(child: _buildTeamScorecardHeader(match.teamA, '${match.scoreA} (${match.oversA})')),
          FadeInUp(
            child: _buildBatterScoreTable([
              {'name': 'Rohit Sharma', 'status': 'b Wellalage', 'r': '53', 'b': '48', '4s': '7', '6s': '2', 'sr': '110.4'},
              {'name': 'Shubman Gill', 'status': 'b Wellalage', 'r': '19', 'b': '25', '4s': '2', '6s': '0', 'sr': '76.0'},
              {'name': 'Virat Kohli', 'status': 'c Shanaka b Wellalage', 'r': '3', 'b': '12', '4s': '0', '6s': '0', 'sr': '25.0'},
              {'name': 'Ishan Kishan', 'status': 'c sub b Wellalage', 'r': '33', 'b': '61', '4s': '1', '6s': '1', 'sr': '54.1'},
              {'name': 'KL Rahul', 'status': 'c & b Wellalage', 'r': '39', 'b': '44', '4s': '2', '6s': '0', 'sr': '88.6'},
            ]),
          ),
          const SizedBox(height: 24),
          FadeInLeft(delay: const Duration(milliseconds: 200), child: _buildTeamScorecardHeader(match.teamB, '${match.scoreB} (${match.oversB})')),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildBatterScoreTable([
              {'name': 'P Nissanka', 'status': 'c Rahul b Bumrah', 'r': '6', 'b': '18', '4s': '1', '6s': '0', 'sr': '33.3'},
              {'name': 'D Karunaratne', 'status': 'c Gill b Siraj', 'r': '2', 'b': '12', '4s': '0', '6s': '0', 'sr': '16.6'},
              {'name': 'K Mendis', 'status': 'c sub b Bumrah', 'r': '15', 'b': '16', '4s': '3', '6s': '0', 'sr': '93.7'},
              {'name': 'S Samarawickrama', 'status': 'st Rahul b Kuldeep', 'r': '17', 'b': '31', '4s': '1', '6s': '0', 'sr': '54.8'},
              {'name': 'D de Silva*', 'status': 'not out', 'r': '30', 'b': '44', '4s': '4', '6s': '0', 'sr': '68.1'},
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryView() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 15,
      itemBuilder: (context, index) {
        return FadeInRight(
          delay: Duration(milliseconds: 100 * (index % 5)),
          child: _buildCommentaryItem(
            '26.${6 - (index % 6)}',
            'Kuldeep Yadav to Wellalage, 1 run, tossed up on middle, Wellalage leans forward and tucks it towards deep mid-wicket for a single.',
            isWicket: index == 3,
          ),
        );
      },
    );
  }

  Widget _buildSquadsView(MatchModel match) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(child: _buildSquadHeader(match.teamA)),
          FadeInUp(child: _buildSquadList(['Rohit Sharma (c)', 'Shubman Gill', 'Virat Kohli', 'KL Rahul (wk)', 'Ishan Kishan', 'Hardik Pandya', 'Ravindra Jadeja', 'Axar Patel', 'Kuldeep Yadav', 'Jasprit Bumrah', 'Mohammed Siraj'])),
          const SizedBox(height: 24),
          FadeInLeft(delay: const Duration(milliseconds: 200), child: _buildSquadHeader(match.teamB)),
          FadeInUp(delay: const Duration(milliseconds: 200), child: _buildSquadList(['Pathum Nissanka', 'Dimuth Karunaratne', 'Kusal Mendis (wk)', 'Sadeera Samarawickrama', 'Charith Asalanka', 'Dhananjaya de Silva', 'Dasun Shanaka (c)', 'Dunith Wellalage', 'Maheesh Theekshana', 'Kasun Rajitha', 'Matheesha Pathirana'])),
        ],
      ),
    );
  }

  Widget _buildInfoView(MatchModel match) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: FadeInUp(child: _buildMatchInformation(match)),
    );
  }

  Widget _buildSquadHeader(String team) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Text(team, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildSquadList(List<String> players) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: players.map((player) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(player, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
      )).toList(),
    );
  }

  Widget _buildCommentaryItem(String over, String text, {bool isWicket = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(over, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWicket)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text('WICKET', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScorecardHeader(String team, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(team, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(score, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBatterScoreTable(List<Map<String, String>> batters) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: const [
              Expanded(flex: 4, child: Text('Batter', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('R', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('B', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('4s', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('6s', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(flex: 2, child: Text('SR', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
            ],
          ),
        ),
        ...batters.map((b) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(flex: 4, child: Text(b['name']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
                  Expanded(child: Text(b['r']!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
                  Expanded(child: Text(b['b']!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                  Expanded(child: Text(b['4s']!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                  Expanded(child: Text(b['6s']!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                  Expanded(flex: 2, child: Text(b['sr']!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
                ],
              ),
              Text(b['status']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        )).toList(),
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

  Widget _buildStatusMessage(MatchModel match) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        match.status,
        style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w500),
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
                Expanded(child: Text('4s', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('6s', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('Strike', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              ],
            ),
          ),
          _buildBatterRow('D Silva*', '30 (44)', '4', '0', '68.18', isTarget: true),
          _buildBatterRow('D Wellalage', '8 (14)', '0', '0', '57.14'),
          const Divider(height: 32, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildBatterRow(String name, String runs, String fours, String sixes, String strike, {bool isTarget = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name, style: TextStyle(color: isTarget ? AppColors.primary : AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500))),
          Expanded(flex: 2, child: Text(runs, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(child: Text(fours, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
          Expanded(child: Text(sixes, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
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
          const Text('Match Score', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallTeamLogo(match.teamA, match.teamALogo),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('${match.scoreA}  -  ${match.scoreB == '-' ? '0/0' : match.scoreB}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
        CachedNetworkImage(
          imageUrl: logo,
          width: 32,
          height: 32,
          errorWidget: (context, url, error) => const Icon(Icons.sports_cricket, color: AppColors.textMuted, size: 32),
        ),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMatchInformation(MatchModel match) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Match Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildInfoRow('Series', match.series),
          _buildInfoRow('Venue', match.venue),
          _buildInfoRow('Time', match.time),
          _buildInfoRow('Toss', 'India, elected to bat first'),
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
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
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
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
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
        Text(name, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
          child: const Text('DRS', style: TextStyle(color: AppColors.accent, fontSize: 8, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
