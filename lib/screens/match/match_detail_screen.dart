import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../providers/match_provider.dart';
import '../../models/match_model.dart';
import '../../widgets/win_prediction.dart';
import 'package:intl/intl.dart';

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
    Future.microtask(() {
      if (mounted) {
        final provider = context.read<MatchProvider>();
        provider.clearMatchDetails();
        provider.fetchMatchDetails(widget.matchId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.watch<MatchProvider>();
    
    // Find the match in the list or use a placeholder if not loaded yet
    MatchModel? match;
    try {
      match = matchProvider.matches.firstWhere((m) => m.id == widget.matchId);
    } catch (e) {
      // If matches aren't loaded in provider yet, we might need to fetch them
      // but usually they are loaded from the home screen.
    }

    if (match == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => context.read<MatchProvider>().fetchMatchDetails(widget.matchId, forceRefresh: true),
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
                _buildLiveView(match, matchProvider),
                _buildScorecardView(matchProvider),
                _buildCommentaryView(matchProvider),
                _buildSquadsView(matchProvider),
                _buildInfoView(matchProvider),
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

  /// Miniscore appears on commentary / overs payloads; scorecard may omit it.
  Map<String, dynamic>? _miniscoreMap(MatchProvider provider) {
    final comm = provider.matchCommentary?['miniscore'];
    if (comm is Map<String, dynamic>) return comm;
    if (comm is Map) return Map<String, dynamic>.from(comm);
    final sc = provider.matchScorecard?['miniscore'];
    if (sc is Map<String, dynamic>) return sc;
    if (sc is Map) return Map<String, dynamic>.from(sc);
    final ov = provider.matchOvers;
    if (ov is Map<String, dynamic>) return ov;
    if (ov is Map) return Map<String, dynamic>.from(ov!);
    return null;
  }

  List<Map<String, dynamic>>? _bowlersFromMiniscore(Map<String, dynamic>? m) {
    if (m == null) return null;
    final list = <Map<String, dynamic>>[];
    void add(Map<dynamic, dynamic>? b) {
      if (b == null) return;
      final name = b['bowlName'] ?? b['name'];
      if (name == null || name.toString().isEmpty) return;
      list.add({
        'name': name.toString(),
        'wickets': b['bowlWkts'] ?? b['wickets'] ?? 0,
        'runs': b['bowlRuns'] ?? b['runs'] ?? 0,
        'overs': b['bowlOvs'] ?? b['overs'] ?? 0,
        'economy': b['bowlEcon'] ?? b['economy'] ?? 0,
      });
    }
    add(m['bowlerStriker'] as Map?);
    add(m['bowlerNonStriker'] as Map?);
    return list.isEmpty ? null : list;
  }

  List<Map<String, dynamic>>? _battersFromMiniscore(Map<String, dynamic>? m) {
    if (m == null) return null;
    final list = <Map<String, dynamic>>[];
    void add(Map<dynamic, dynamic>? b) {
      if (b == null) return;
      final name = b['batName'] ?? b['name'];
      if (name == null || name.toString().isEmpty) return;
      final id = b['batId'] ?? b['id'];
      if (id == 0) return;
      list.add({
        'name': name.toString(),
        'runs': b['batRuns'] ?? b['runs'] ?? 0,
        'balls': b['batBalls'] ?? b['balls'] ?? 0,
        'fours': b['batFours'] ?? b['fours'] ?? 0,
        'sixes': b['batSixes'] ?? b['sixes'] ?? 0,
        'strikeRate': b['batStrikeRate'] ?? b['strikeRate'] ?? 0,
      });
    }
    add(m['batsmanStriker'] as Map?);
    add(m['batsmanNonStriker'] as Map?);
    return list.isEmpty ? null : list;
  }

  Widget _buildLiveView(MatchModel match, MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final miniscore = _miniscoreMap(provider);
    final crr = (miniscore?['currentRunRate'] ?? miniscore?['crr'])?.toString() ?? '0.00';
    final rrr = (miniscore?['requiredRunRate'] ?? miniscore?['rrr'])?.toString() ?? '0.00';
    final target = miniscore?['target']?.toString() ?? '-';
    final status = miniscore?['status'] ?? match.status;
    final bowlers = _bowlersFromMiniscore(miniscore);
    final batters = _battersFromMiniscore(miniscore);
    final rawPartnership = miniscore?['partnerShip'] ?? miniscore?['partnership'];
    Map<String, dynamic>? partnershipMap;
    if (rawPartnership is Map) {
      partnershipMap = Map<String, dynamic>.from(rawPartnership as Map);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          FadeInDown(child: _buildStatsHeader(crr, rrr, target)),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: WinPredictionWidget(
              teamA: match.teamA,
              teamB: match.teamB,
              percentageA: 60, // Ideally from API if available
              percentageB: 40,
            ),
          ),
          if (provider.matchOvers != null)
            FadeInUp(delay: const Duration(milliseconds: 300), child: _buildOversTimeline(provider.matchOvers!)),

          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildBowlerSection(bowlers ?? (miniscore?['bowlerStrip'] as List?)),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: _buildBatterSection(
              batters ?? (miniscore?['batsmanStrip'] as List?),
              partnershipMap,
            ),
          ),
          
          FadeInUp(delay: const Duration(milliseconds: 600), child: _buildLargeScoreDisplay(match)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(String crr, String rrr, String target) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem('CRR', crr),
          _buildStatItem('RRR', rrr),
          _buildStatItem('Target', target),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOversTimeline(Map<String, dynamic> oversData) {
    final overSummary = oversData['overSummaryList'] as List?;
    if (overSummary == null || overSummary.isEmpty) return const SizedBox.shrink();

    final lastOver = Map<String, dynamic>.from(overSummary.first as Map);
    final rawBalls = lastOver['balls'] as List?;
    final oSummary = lastOver['o_summary'] as String?;
    final List<dynamic> balls;
    if (rawBalls != null && rawBalls.isNotEmpty) {
      balls = rawBalls;
    } else if (oSummary != null && oSummary.trim().isNotEmpty) {
      balls = oSummary.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    } else {
      balls = [];
    }
    if (balls.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overs Timeline', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('OVER ${lastOver['overNum']}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: balls.map((ball) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.1)),
                        ),
                        child: Center(
                          child: Text(
                            ball.toString(),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildBowlerSection(List? bowlers) {
    if (bowlers == null || bowlers.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Bowler', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('Wkt-Runs', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('Overs', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
                Expanded(child: Text('Econ', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              ],
            ),
          ),
          ...bowlers.map((b) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(b['name'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                Expanded(child: Text("${b['wickets']}-${b['runs']}", textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                Expanded(child: Text(b['overs']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                Expanded(child: Text(b['economy']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
              ],
            ),
          )),
          const Divider(height: 24, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildBatterSection(List? batters, Map? partnership) {
    if (batters == null || batters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('On Crease', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
              if (partnership != null)
                Text(' - Partnership: ${partnership['runs']} (${partnership['balls']})', 
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(flex: 3, child: Text('Batter', style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('Run (Ball)', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('4s', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('6s', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
              Expanded(child: Text('Strike', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11))),
            ],
          ),
          ...batters.map((b) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(b['name'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
                Expanded(child: Text("${b['runs']} (${b['balls']})", textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                Expanded(child: Text(b['fours']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                Expanded(child: Text(b['sixes']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
                Expanded(child: Text(b['strikeRate']?.toString() ?? '0', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
              ],
            ),
          )),
          const Divider(height: 24, color: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildScorecardView(MatchProvider provider) {
    if (provider.isLoading && provider.matchScorecard == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final scorecard = provider.matchScorecard;
    if (scorecard == null || scorecard['scoreCard'] == null) {
      return const Center(child: Text("Scorecard not available", style: TextStyle(color: Colors.white)));
    }

    final innings = scorecard['scoreCard'] as List;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: innings.length,
      itemBuilder: (context, index) {
        final inning = Map<String, dynamic>.from(innings[index] as Map);
        final bat = inning['batTeamDetails'];
        final batMap = bat is Map ? Map<String, dynamic>.from(bat as Map) : <String, dynamic>{};
        final teamName = batMap['batTeamName'] ?? inning['batTeamName'] ?? 'Team';
        final sd = inning['scoreDetails'];
        final sdMap = sd is Map ? Map<String, dynamic>.from(sd as Map) : <String, dynamic>{};
        final runs = sdMap['runs'] ?? inning['runs'] ?? 0;
        final wkts = sdMap['wickets'] ?? inning['wickets'] ?? 0;
        final overs = sdMap['overs'] ?? inning['overs'] ?? 0;
        final score = '$runs/$wkts ($overs)';

        final batsmenRaw = batMap['batsmenData'];
        final batsmen = batsmenRaw is Map ? Map<String, dynamic>.from(batsmenRaw as Map) : <String, dynamic>{};
        final batKeys = batsmen.keys.toList()
          ..sort((a, b) {
            final na = int.tryParse(a.replaceFirst(RegExp(r'bat_'), '')) ?? 0;
            final nb = int.tryParse(b.replaceFirst(RegExp(r'bat_'), '')) ?? 0;
            return na.compareTo(nb);
          });

        final bowlTeam = inning['bowlTeamDetails'];
        final bowlMap = bowlTeam is Map ? Map<String, dynamic>.from(bowlTeam as Map) : <String, dynamic>{};
        final bowlersRaw = bowlMap['bowlersData'];
        final bowlersMap = bowlersRaw is Map ? Map<String, dynamic>.from(bowlersRaw as Map) : <String, dynamic>{};
        final bowlKeys = bowlersMap.keys.toList()
          ..sort((a, b) {
            final na = int.tryParse(a.replaceFirst(RegExp(r'bowl_'), '')) ?? 0;
            final nb = int.tryParse(b.replaceFirst(RegExp(r'bowl_'), '')) ?? 0;
            return na.compareTo(nb);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInLeft(child: _buildTeamScorecardHeader(teamName.toString(), score)),
            const SizedBox(height: 8),
            if (batKeys.isNotEmpty) ...[
              const Text('Batting', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...batKeys.map((k) {
                final row = Map<String, dynamic>.from(batsmen[k] as Map);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          row['batName']?.toString() ?? '',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${row['runs'] ?? 0} (${row['balls'] ?? 0})',
                          textAlign: TextAlign.end,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (bowlKeys.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Bowling', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...bowlKeys.map((k) {
                final row = Map<String, dynamic>.from(bowlersMap[k] as Map);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          row['bowlName']?.toString() ?? '',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${row['wickets'] ?? 0}-${row['runs'] ?? 0} (${row['overs'] ?? 0})',
                          textAlign: TextAlign.end,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildCommentaryView(MatchProvider provider) {
    if (provider.isLoading && provider.matchCommentary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final commData = provider.matchCommentary;
    if (commData == null || commData['commentaryList'] == null) {
      return const Center(child: Text("Commentary not available", style: TextStyle(color: Colors.white)));
    }

    final commentaryList = commData['commentaryList'] as List;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: commentaryList.length,
      itemBuilder: (context, index) {
        final item = Map<String, dynamic>.from(commentaryList[index] as Map);
        final over = item['overNumber']?.toString() ?? '';
        final text = _formatCommentaryText(item);
        final isWicket = item['event']?.toString() == 'WICKET' || item['wicket'] == true;

        return FadeInRight(
          delay: Duration(milliseconds: 50 * (index % 10)),
          child: _buildCommentaryItem(over, text, isWicket: isWicket),
        );
      },
    );
  }

  List<Map<String, dynamic>> _playerRows(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Widget _buildSquadPlayerList(List<Map<String, dynamic>> players) {
    if (players.isEmpty) {
      return const Text('Nessun giocatore in elenco', style: TextStyle(color: AppColors.textMuted, fontSize: 12));
    }
    final playing = players.where((p) => p['substitute'] != true).toList();
    final bench = players.where((p) => p['substitute'] == true).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (playing.isNotEmpty) ...[
          const Text('In campo', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...playing.map(_buildSquadPlayerRow),
        ],
        if (bench.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Panchina / riserve', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...bench.map(_buildSquadPlayerRow),
        ],
      ],
    );
  }

  Widget _buildSquadPlayerRow(Map<String, dynamic> pm) {
    final sub = pm['substitute'] == true ? ' (ris.)' : '';
    final name = pm['name'] ?? pm['fullName'] ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pm['captain'] == true)
            const Padding(padding: EdgeInsets.only(right: 6), child: Text('©', style: TextStyle(color: AppColors.primary, fontSize: 12))),
          if (pm['keeper'] == true)
            const Padding(padding: EdgeInsets.only(right: 4), child: Text('†', style: TextStyle(color: AppColors.primary, fontSize: 12))),
          Expanded(child: Text('$name$sub', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12))),
          if ((pm['role'] ?? '').toString().isNotEmpty)
            SizedBox(
              width: 100,
              child: Text(pm['role'].toString(), textAlign: TextAlign.end, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  Widget _buildSquadsView(MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final info = provider.matchInfo;
    if (info == null) {
      return const Center(child: Text("Squad info not available", style: TextStyle(color: Colors.white)));
    }

    final root = info['matchInfo'] != null ? Map<String, dynamic>.from(info['matchInfo'] as Map) : Map<String, dynamic>.from(info);
    final t1 = root['team1'];
    final t2 = root['team2'];
    if (t1 == null || t2 == null) {
      return const Center(child: Text("Squad info not available", style: TextStyle(color: Colors.white)));
    }

    final team1Map = Map<String, dynamic>.from(t1 as Map);
    final team2Map = Map<String, dynamic>.from(t2 as Map);
    final team1Name = team1Map['name'] ?? team1Map['teamName'] ?? 'Team 1';
    final team2Name = team2Map['name'] ?? team2Map['teamName'] ?? 'Team 2';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(child: _buildSquadHeader(team1Name.toString())),
          _buildSquadPlayerList(_playerRows(team1Map['playerDetails'])),
          const SizedBox(height: 24),
          FadeInLeft(delay: const Duration(milliseconds: 200), child: _buildSquadHeader(team2Name.toString())),
          _buildSquadPlayerList(_playerRows(team2Map['playerDetails'])),
        ],
      ),
    );
  }

  Widget _buildInfoView(MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final info = provider.matchInfo;
    if (info == null) return const Center(child: Text("Match info not available"));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: FadeInUp(child: _buildMatchInformation(info)),
    );
  }

  Widget _buildSquadHeader(String team) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Text(team, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  /// Sostituisce segnaposti tipo B0$, B1$ con i valori in [commentaryFormats.bold].
  String _formatCommentaryText(Map<String, dynamic> item) {
    var text = item['commText']?.toString() ?? '';
    final fmt = item['commentaryFormats'];
    if (fmt is! Map) return text;
    final bold = fmt['bold'];
    if (bold is! Map) return text;
    final ids = bold['formatId'];
    final values = bold['formatValue'];
    if (ids is! List || values is! List || ids.length != values.length) return text;
    for (var i = 0; i < ids.length; i++) {
      text = text.replaceAll(ids[i].toString(), values[i].toString());
    }
    return text;
  }

  Widget _buildCommentaryItem(String over, String text, {bool isWicket = false}) {
    // Basic HTML tag stripping if needed
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (over.isNotEmpty)
            SizedBox(
              width: 40,
              child: Text(over, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 13)),
            ),
          const SizedBox(width: 12),
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
                Text(cleanText, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
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

  Widget _buildMatchInformation(Map<String, dynamic> info) {
    final matchInfoRaw = info['matchInfo'] ?? info;
    final matchInfo = matchInfoRaw is Map ? Map<String, dynamic>.from(matchInfoRaw as Map) : <String, dynamic>{};
    final rootVenue = info['venueInfo'];
    final rootVenueMap = rootVenue is Map ? Map<String, dynamic>.from(rootVenue as Map) : <String, dynamic>{};
    final miVenue = matchInfo['venue'];
    final miVenueMap = miVenue is Map ? Map<String, dynamic>.from(miVenue as Map) : <String, dynamic>{};
    final nestedVenue = matchInfo['venueInfo'];
    final nestedVenueMap = nestedVenue is Map ? Map<String, dynamic>.from(nestedVenue as Map) : <String, dynamic>{};

    final ground = rootVenueMap['ground'] ?? nestedVenueMap['ground'] ?? miVenueMap['name'] ?? '';
    final city = rootVenueMap['city'] ?? nestedVenueMap['city'] ?? miVenueMap['city'] ?? '';
    final venueLine = [ground, city].where((s) => s.toString().trim().isNotEmpty).join(', ');

    final toss = matchInfo['tossResults'];
    String tossLine = 'N/A';
    if (toss is Map) {
      final tw = toss['tossWinnerName'] ?? toss['tossWinner'];
      final dec = toss['decision'];
      if (tw != null && dec != null) {
        tossLine = '$tw opt to $dec';
      }
    } else if (matchInfo['toss'] != null) {
      tossLine = matchInfo['toss'].toString();
    }

    final seriesObj = matchInfo['series'];
    final seriesName = seriesObj is Map
        ? (seriesObj['name'] ?? seriesObj['seriesName'])?.toString()
        : matchInfo['seriesName']?.toString();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Match Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildInfoRow('Toss', tossLine),
          _buildInfoRow('Series', seriesName ?? 'N/A'),
          _buildInfoRow('Season', matchInfo['season']?.toString() ?? 'N/A'),
          _buildInfoRow('Match Number', matchInfo['matchNum']?.toString() ?? matchInfo['matchDescription']?.toString() ?? 'N/A'),
          _buildInfoRow('Venue', venueLine.isEmpty ? 'N/A' : venueLine),
          _buildInfoRow(
            'Match Days',
            matchInfo['matchStartTimestamp'] != null
                ? DateFormat('dd MMMM yyyy').format(
                    DateTime.fromMillisecondsSinceEpoch(int.parse(matchInfo['matchStartTimestamp'].toString())),
                  )
                : 'N/A',
          ),
          _buildInfoRow('Umpires', matchInfo['umpire1']?['name'] ?? 'N/A'),
          _buildInfoRow('TV Umpire', matchInfo['umpire3']?['name'] ?? 'N/A'),
          _buildInfoRow('Match Referee', matchInfo['referee']?['name'] ?? 'N/A'),
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
}
