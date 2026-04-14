import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../providers/match_provider.dart';
import '../../models/match_model.dart';
import '../../widgets/win_prediction.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _tabs = [
    _Tab('LIVE',        Icons.sensors_rounded),
    _Tab('SCORECARD',   Icons.table_rows_rounded),
    _Tab('COMMENTARY',  Icons.chat_bubble_outline_rounded),
    _Tab('SQUADS',      Icons.people_rounded),
    _Tab('INFO',        Icons.info_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    Future.microtask(() {
      if (!mounted) return;
      final p = context.read<MatchProvider>();
      p.clearMatchDetails();
      p.fetchMatchDetails(widget.matchId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ──────────────────────────────────────────────────────────

  Map<String, dynamic>? _miniscore(MatchProvider p) {
    for (final src in [p.matchCommentary, p.matchScorecard]) {
      final m = src?['miniscore'];
      if (m is Map) return Map<String, dynamic>.from(m);
    }
    if (p.matchOvers is Map) {
      return Map<String, dynamic>.from(p.matchOvers as Map);
    }
    return null;
  }

  List<Map<String, dynamic>>? _bowlers(Map<String, dynamic>? m) {
    if (m == null) return null;
    final out = <Map<String, dynamic>>[];
    void add(dynamic b) {
      if (b is! Map) return;
      final name = b['bowlName'] ?? b['name'];
      if (name == null || name.toString().isEmpty) return;
      out.add({
        'name': name.toString(),
        'wickets': b['bowlWkts'] ?? b['wickets'] ?? 0,
        'runs': b['bowlRuns'] ?? b['runs'] ?? 0,
        'overs': b['bowlOvs'] ?? b['overs'] ?? 0,
        'economy': b['bowlEcon'] ?? b['economy'] ?? 0,
      });
    }
    add(m['bowlerStriker']);
    add(m['bowlerNonStriker']);
    return out.isEmpty ? null : out;
  }

  List<Map<String, dynamic>>? _batters(Map<String, dynamic>? m) {
    if (m == null) return null;
    final out = <Map<String, dynamic>>[];
    void add(dynamic b) {
      if (b is! Map) return;
      final name = b['batName'] ?? b['name'];
      if (name == null || name.toString().isEmpty) return;
      if ((b['batId'] ?? b['id'] ?? 0) == 0) return;
      out.add({
        'name': name.toString(),
        'runs': b['batRuns'] ?? b['runs'] ?? 0,
        'balls': b['batBalls'] ?? b['balls'] ?? 0,
        'fours': b['batFours'] ?? b['fours'] ?? 0,
        'sixes': b['batSixes'] ?? b['sixes'] ?? 0,
        'strikeRate': b['batStrikeRate'] ?? b['strikeRate'] ?? 0,
      });
    }
    add(m['batsmanStriker']);
    add(m['batsmanNonStriker']);
    return out.isEmpty ? null : out;
  }

  String _fmtCommentary(Map<String, dynamic> item) {
    var text = item['commText']?.toString() ?? '';
    final fmt = item['commentaryFormats'];
    if (fmt is Map) {
      final bold = fmt['bold'];
      if (bold is Map) {
        final ids = bold['formatId'];
        final vals = bold['formatValue'];
        if (ids is List && vals is List && ids.length == vals.length) {
          for (int i = 0; i < ids.length; i++) {
            text = text.replaceAll(ids[i].toString(), vals[i].toString());
          }
        }
      }
    }
    return text.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ');
  }

  // ── Root build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchProvider>();
    MatchModel? match;
    try {
      match = provider.matches.firstWhere((m) => m.id == widget.matchId);
    } catch (_) {}

    if (match == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(match, provider),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _liveTab(match, provider),
                  _scorecardTab(provider),
                  _commentaryTab(provider),
                  _squadsTab(provider),
                  _infoTab(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(MatchModel match, MatchProvider provider) {
    final isLive = match.status.toLowerCase().contains('live') ||
        match.status.toLowerCase().contains('progress');

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 10, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isLive
                ? AppColors.screenWarmHeaderLive
                : AppColors.screenNavyHeader,
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Back + refresh row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.07)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary, size: 14),
                ),
              ),
              const Spacer(),
              // Live badge
              if (isLive)
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.live
                          .withOpacity(0.10 + _pulseAnim.value * 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.live
                            .withOpacity(0.32 + _pulseAnim.value * 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.live.withOpacity(
                                0.6 + _pulseAnim.value * 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text('LIVE',
                            style: TextStyle(
                                color: AppColors.live,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  provider.fetchMatchDetails(widget.matchId,
                      forceRefresh: true);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.07)),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: AppColors.primary, size: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Team score row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Team A
              Expanded(
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: match.teamALogo,
                      width: 40,
                      height: 40,
                      errorWidget: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sports_cricket_rounded,
                            color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      match.teamA,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      match.scoreA.isEmpty ? '--' : match.scoreA,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20),
                    ),
                    if (match.oversA.isNotEmpty &&
                        match.oversA != '-')
                      Text(
                        match.oversA,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 10),
                      ),
                  ],
                ),
              ),

              // VS
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color:
                          AppColors.secondary.withOpacity(0.20)),
                    ),
                    child: Text(
                      'vs',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              // Team B
              Expanded(
                child: Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: match.teamBLogo,
                      width: 40,
                      height: 40,
                      errorWidget: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sports_cricket_rounded,
                            color: AppColors.secondary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      match.teamB,
                      style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      match.scoreB == '-'
                          ? 'Yet to bat'
                          : match.scoreB.isEmpty
                          ? '--'
                          : match.scoreB,
                      style: TextStyle(
                        color: match.scoreB == '-'
                            ? AppColors.textMuted
                            : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    if (match.oversB.isNotEmpty &&
                        match.oversB != '-')
                      Text(
                        match.oversB,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 10),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Status line
          if (match.status.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isLive
                    ? AppColors.live.withOpacity(0.08)
                    : AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isLive
                      ? AppColors.live.withOpacity(0.20)
                      : Colors.white.withOpacity(0.06),
                ),
              ),
              child: Text(
                match.status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isLive
                      ? AppColors.live
                      : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: EdgeInsets.zero,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryLight, AppColors.primary],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.38),
              blurRadius: 10,
              spreadRadius: -2,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.textMuted,
        labelPadding: EdgeInsets.zero,
        tabs: _tabs.map((t) => Tab(
          height: 34,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.icon, size: 12),
                const SizedBox(width: 5),
                Text(t.label,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800,
                        letterSpacing: 0.4)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  // ── LIVE TAB ──────────────────────────────────────────────────────────────

  Widget _liveTab(MatchModel match, MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    final ms = _miniscore(provider);
    final crr = (ms?['currentRunRate'] ?? ms?['crr'])?.toString() ?? '--';
    final rrr = (ms?['requiredRunRate'] ?? ms?['rrr'])?.toString() ?? '--';
    final target = ms?['target']?.toString() ?? '--';
    final bowlers = _bowlers(ms);
    final batters = _batters(ms);
    Map<String, dynamic>? partnership;
    final rawP = ms?['partnerShip'] ?? ms?['partnership'];
    if (rawP is Map) {
      partnership = Map<String, dynamic>.from(rawP);
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          FadeInDown(child: _statsStrip(crr, rrr, target)),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: WinPredictionWidget(
              teamA: match.teamA,
              teamB: match.teamB,
              percentageA: 60,
              percentageB: 40,
            ),
          ),
          if (provider.matchOvers != null)
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _oversTimeline(provider.matchOvers!),
            ),
          if (batters != null)
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _batterSection(batters, partnership),
            ),
          if (bowlers != null)
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _bowlerSection(bowlers),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _statsStrip(String crr, String rrr, String target) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(child: _statPill('CRR', crr, AppColors.primary)),
          Container(width: 1, height: 30, color: Colors.white10),
          Expanded(child: _statPill('RRR', rrr, AppColors.live)),
          Container(width: 1, height: 30, color: Colors.white10),
          Expanded(child: _statPill('Target', target, AppColors.chartLine2)),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style:
            TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 19,
                fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _oversTimeline(Map<String, dynamic> oversData) {
    final overList = oversData['overSummaryList'] as List?;
    if (overList == null || overList.isEmpty) return const SizedBox();

    final lastOver = Map<String, dynamic>.from(overList.first as Map);
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
    if (balls.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'OVER ${lastOver['overNum'] ?? ''}',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: balls.map((ball) {
                      final b = ball.toString().trim();
                      final color = _ballColor(b);
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: color.withOpacity(0.40)),
                        ),
                        child: Center(
                          child: Text(b,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _ballColor(String b) {
    if (b == 'W') return AppColors.live;
    if (b == '4') return AppColors.four;
    if (b == '6') return AppColors.six;
    if (b == '0') return AppColors.textMuted;
    if (b == 'Wd' || b == 'Nb') return AppColors.extra;
    return AppColors.textSecondary;
  }

  Widget _batterSection(List<Map<String, dynamic>> batters, Map? partnership) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('ON CREASE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
                if (partnership != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'P\'ship: ${partnership['runs']} (${partnership['balls']})',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(
              children: const [
                Expanded(flex: 3, child: _ColHeader('BATTER')),
                Expanded(child: _ColHeader('R (B)', center: true)),
                Expanded(child: _ColHeader('4s', center: true)),
                Expanded(child: _ColHeader('6s', center: true)),
                Expanded(child: _ColHeader('SR', center: true)),
              ],
            ),
          ),

          ...batters.map((b) => Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(b['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: Text(
                    '${b['runs']}(${b['balls']})',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: _ballStat(b['fours']?.toString() ?? '0',
                      AppColors.four),
                ),
                Expanded(
                  child: _ballStat(b['sixes']?.toString() ?? '0',
                      AppColors.six),
                ),
                Expanded(
                  child: Text(
                    b['strikeRate']?.toString() ?? '0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _ballStat(String val, Color color) {
    return Text(
      val,
      textAlign: TextAlign.center,
      style: TextStyle(
          color: color, fontSize: 12, fontWeight: FontWeight.w700),
    );
  }

  Widget _bowlerSection(List<Map<String, dynamic>> bowlers) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10))),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.chartLine2,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('BOWLING',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(
              children: const [
                Expanded(flex: 3, child: _ColHeader('BOWLER')),
                Expanded(child: _ColHeader('W-R', center: true)),
                Expanded(child: _ColHeader('OVS', center: true)),
                Expanded(child: _ColHeader('ECON', center: true)),
              ],
            ),
          ),
          ...bowlers.map((b) => Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(b['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: Text(
                    '${b['wickets']}-${b['runs']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.live,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(b['overs']?.toString() ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ),
                Expanded(
                  child: Text(b['economy']?.toString() ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── SCORECARD TAB ─────────────────────────────────────────────────────────

  Widget _scorecardTab(MatchProvider provider) {
    if (provider.isLoading && provider.matchScorecard == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    final sc = provider.matchScorecard;
    if (sc == null || sc['scoreCard'] == null) {
      return _emptyState('Scorecard not available');
    }

    final innings = sc['scoreCard'] as List;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: innings.length,
      itemBuilder: (_, i) {
        final inn = Map<String, dynamic>.from(innings[i] as Map);
        final batTeam = inn['batTeamDetails'] is Map
            ? Map<String, dynamic>.from(inn['batTeamDetails'] as Map)
            : <String, dynamic>{};
        final sd = inn['scoreDetails'] is Map
            ? Map<String, dynamic>.from(inn['scoreDetails'] as Map)
            : <String, dynamic>{};

        final teamName =
        (batTeam['batTeamName'] ?? inn['batTeamName'] ?? 'Team')
            .toString();
        final score =
            '${sd['runs'] ?? 0}/${sd['wickets'] ?? 0} (${sd['overs'] ?? 0})';

        final batsmenRaw = batTeam['batsmenData'];
        final batsmen = batsmenRaw is Map
            ? Map<String, dynamic>.from(batsmenRaw as Map)
            : <String, dynamic>{};
        final batKeys = batsmen.keys.toList()
          ..sort((a, b) {
            int n(String s) =>
                int.tryParse(s.replaceFirst(RegExp(r'bat_'), '')) ?? 0;
            return n(a).compareTo(n(b));
          });

        final bowlTeam = inn['bowlTeamDetails'] is Map
            ? Map<String, dynamic>.from(inn['bowlTeamDetails'] as Map)
            : <String, dynamic>{};
        final bowlersRaw = bowlTeam['bowlersData'];
        final bowlers = bowlersRaw is Map
            ? Map<String, dynamic>.from(bowlersRaw as Map)
            : <String, dynamic>{};
        final bowlKeys = bowlers.keys.toList()
          ..sort((a, b) {
            int n(String s) =>
                int.tryParse(s.replaceFirst(RegExp(r'bowl_'), '')) ?? 0;
            return n(a).compareTo(n(b));
          });

        return FadeInUp(
          delay: Duration(milliseconds: 80 * i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border:
              Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Innings header
                Container(
                  padding:
                  const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.12),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                    border: const Border(
                        bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      Text(teamName,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                      const Spacer(),
                      Text(score,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ],
                  ),
                ),

                if (batKeys.isNotEmpty) ...[
                  _sectionLabel('Batting', AppColors.primary),
                  _batHeaderRow(),
                  ...batKeys.map((k) {
                    final row = Map<String, dynamic>.from(
                        batsmen[k] as Map);
                    return _batRow(row);
                  }),
                ],

                if (bowlKeys.isNotEmpty) ...[
                  _sectionLabel('Bowling', AppColors.chartLine2),
                  _bowlHeaderRow(),
                  ...bowlKeys.map((k) {
                    final row = Map<String, dynamic>.from(
                        bowlers[k] as Map);
                    return _bowlRow(row);
                  }),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8)),
        ],
      ),
    );
  }

  Widget _batHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _ColHeader('BATTER')),
          Expanded(child: _ColHeader('R', center: true)),
          Expanded(child: _ColHeader('B', center: true)),
          Expanded(child: _ColHeader('4s', center: true)),
          Expanded(child: _ColHeader('6s', center: true)),
          Expanded(child: _ColHeader('SR', center: true)),
        ],
      ),
    );
  }

  Widget _batRow(Map<String, dynamic> r) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(r['batName']?.toString() ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          Expanded(
            child: Text(r['runs']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(r['balls']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(r['fours']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.four,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(r['sixes']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.six,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(r['strikeRate']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _bowlHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Expanded(flex: 3, child: _ColHeader('BOWLER')),
          Expanded(child: _ColHeader('O', center: true)),
          Expanded(child: _ColHeader('M', center: true)),
          Expanded(child: _ColHeader('R', center: true)),
          Expanded(child: _ColHeader('W', center: true)),
          Expanded(child: _ColHeader('ECON', center: true)),
        ],
      ),
    );
  }

  Widget _bowlRow(Map<String, dynamic> r) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(r['bowlName']?.toString() ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
          Expanded(
            child: Text(r['overs']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(r['maidens']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(r['runs']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
          Expanded(
            child: Text(r['wickets']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.live,
                    fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: Text(r['economy']?.toString() ?? '0',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ── COMMENTARY TAB ────────────────────────────────────────────────────────

  Widget _commentaryTab(MatchProvider provider) {
    if (provider.isLoading && provider.matchCommentary == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    final commData = provider.matchCommentary;
    if (commData == null || commData['commentaryList'] == null) {
      return _emptyState('Commentary not available');
    }

    final list = commData['commentaryList'] as List;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = Map<String, dynamic>.from(list[i] as Map);
        final over = item['overNumber']?.toString() ?? '';
        final text = _fmtCommentary(item);
        final isWkt = item['event']?.toString() == 'WICKET' ||
            item['wicket'] == true;
        final isFour =
            item['event']?.toString() == 'FOUR' || item['runs'] == 4;
        final isSix =
            item['event']?.toString() == 'SIX' || item['runs'] == 6;

        Color accentColor = AppColors.textMuted;
        if (isWkt) accentColor = AppColors.live;
        else if (isSix) accentColor = AppColors.six;
        else if (isFour) accentColor = AppColors.four;

        return FadeInRight(
          delay: Duration(milliseconds: 40 * (i % 10)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWkt
                  ? AppColors.live.withOpacity(0.06)
                  : isSix
                  ? AppColors.six.withOpacity(0.05)
                  : isFour
                  ? AppColors.four.withOpacity(0.05)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isWkt
                    ? AppColors.live.withOpacity(0.22)
                    : isSix
                    ? AppColors.six.withOpacity(0.18)
                    : isFour
                    ? AppColors.four.withOpacity(0.18)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (over.isNotEmpty)
                  Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text(over,
                        style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isWkt)
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.live,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('WICKET',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8)),
                        )
                      else if (isSix)
                        Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.six,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('SIX',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8)),
                        )
                      else if (isFour)
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.four,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text('FOUR',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8)),
                          ),
                      Text(text,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              height: 1.45)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── SQUADS TAB ────────────────────────────────────────────────────────────

  Widget _squadsTab(MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    final info = provider.matchInfo;
    if (info == null) return _emptyState('Squad info not available');

    final root = info['matchInfo'] != null
        ? Map<String, dynamic>.from(info['matchInfo'] as Map)
        : Map<String, dynamic>.from(info);
    final t1 = root['team1'];
    final t2 = root['team2'];
    if (t1 == null || t2 == null) return _emptyState('Squad info not available');

    final team1 = Map<String, dynamic>.from(t1 as Map);
    final team2 = Map<String, dynamic>.from(t2 as Map);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          FadeInLeft(
              child: _squadCard(
                  team1['name']?.toString() ??
                      team1['teamName']?.toString() ??
                      'Team 1',
                  _playerRows(team1['playerDetails']))),
          const SizedBox(height: 14),
          FadeInLeft(
              delay: const Duration(milliseconds: 150),
              child: _squadCard(
                  team2['name']?.toString() ??
                      team2['teamName']?.toString() ??
                      'Team 2',
                  _playerRows(team2['playerDetails']))),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _playerRows(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Widget _squadCard(String name, List<Map<String, dynamic>> players) {
    final playing = players.where((p) => p['substitute'] != true).toList();
    final bench = players.where((p) => p['substitute'] == true).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.10),
                  Colors.transparent
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              border:
              const Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Text(name,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.3)),
          ),
          if (playing.isNotEmpty) ...[
            _squadSectionLabel('Playing XI'),
            ...playing.map(_playerRow),
          ],
          if (bench.isNotEmpty) ...[
            _squadSectionLabel('Bench / Reserves'),
            ...bench.map(_playerRow),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _squadSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(label,
          style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6)),
    );
  }

  Widget _playerRow(Map<String, dynamic> pm) {
    final name = pm['name'] ?? pm['fullName'] ?? '';
    final isCaptain = pm['captain'] == true;
    final isKeeper = pm['keeper'] == true;
    final role = pm['role']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5))),
      child: Row(
        children: [
          if (isCaptain)
            Container(
              margin: const EdgeInsets.only(right: 5),
              padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('C',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900)),
            ),
          if (isKeeper)
            Container(
              margin: const EdgeInsets.only(right: 5),
              padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.chartLine2.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('WK',
                  style: TextStyle(
                      color: AppColors.chartLine2,
                      fontSize: 9,
                      fontWeight: FontWeight.w900)),
            ),
          Expanded(
            child: Text(name.toString(),
                style: const TextStyle(
                    color: Colors.white, fontSize: 13)),
          ),
          if (role.isNotEmpty)
            Text(role,
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  // ── INFO TAB ──────────────────────────────────────────────────────────────

  Widget _infoTab(MatchProvider provider) {
    if (provider.isLoading && provider.matchInfo == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    final info = provider.matchInfo;
    if (info == null) return _emptyState('Match info not available');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: FadeInUp(child: _matchInfoCard(info)),
    );
  }

  Widget _matchInfoCard(Map<String, dynamic> info) {
    final miRaw = info['matchInfo'] ?? info;
    final mi = miRaw is Map
        ? Map<String, dynamic>.from(miRaw as Map)
        : <String, dynamic>{};

    // Venue
    String venue = 'N/A';
    for (final src in [
      info['venueInfo'],
      mi['venueInfo'],
      mi['venue']
    ]) {
      if (src is Map) {
        final g = src['ground'] ?? src['name'] ?? '';
        final c = src['city'] ?? '';
        final parts = [g, c].where((s) => s.toString().isNotEmpty);
        if (parts.isNotEmpty) {
          venue = parts.join(', ');
          break;
        }
      }
    }

    // Toss
    String toss = 'N/A';
    final tossRaw = mi['tossResults'];
    if (tossRaw is Map) {
      final w = tossRaw['tossWinnerName'] ?? tossRaw['tossWinner'];
      final d = tossRaw['decision'];
      if (w != null && d != null) toss = '$w opt to $d';
    } else if (mi['toss'] != null) {
      toss = mi['toss'].toString();
    }

    // Series
    final seriesRaw = mi['series'];
    final series = seriesRaw is Map
        ? (seriesRaw['name'] ?? seriesRaw['seriesName'])?.toString()
        : mi['seriesName']?.toString();

    // Date
    String date = 'N/A';
    final ts = mi['matchStartTimestamp'];
    if (ts != null) {
      try {
        date = DateFormat('dd MMMM yyyy', 'en_US').format(
            DateTime.fromMillisecondsSinceEpoch(int.parse(ts.toString())));
      } catch (_) {}
    }

    final rows = [
      ('Series', series ?? 'N/A'),
      ('Toss', toss),
      ('Venue', venue),
      ('Match', mi['matchDescription']?.toString() ?? 'N/A'),
      ('Date', date),
      ('Umpire 1', mi['umpire1'] is Map ? (mi['umpire1']['name'] ?? 'N/A') : 'N/A'),
      ('TV Umpire', mi['umpire3'] is Map ? (mi['umpire3']['name'] ?? 'N/A') : 'N/A'),
      ('Referee', mi['referee'] is Map ? (mi['referee']['name'] ?? 'N/A') : 'N/A'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.10),
                  Colors.transparent
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              border:
              const Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 14,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 9),
                const Text('MATCH INFORMATION',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
              ],
            ),
          ),
          ...rows.map((r) => _infoRow(r.$1, r.$2)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
      decoration: const BoxDecoration(
          border:
          Border(top: BorderSide(color: Colors.white10, width: 0.5))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: const Icon(Icons.sports_cricket_outlined,
                size: 30, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Text(msg,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── SUPPORTING WIDGETS ───────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String label;
  final bool center;
  const _ColHeader(this.label, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  const _Tab(this.label, this.icon);
}
