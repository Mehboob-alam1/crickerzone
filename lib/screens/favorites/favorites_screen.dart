import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Mock data — replace with real provider data
  final List<_FavTeam> _teams = [
    _FavTeam('India', '🇮🇳', 'IND', AppColors.indiaBlue, AppColors.indiaOrange, isLive: true, score: '287/4 (45.2 ov)'),
    _FavTeam('Australia', '🇦🇺', 'AUS', AppColors.australiaGreen, AppColors.australiaGold),
    _FavTeam('England', '🏴', 'ENG', AppColors.englandBlue, AppColors.englandRed),
    _FavTeam('Pakistan', '🇵🇰', 'PAK', AppColors.pakistanGreen, AppColors.textPrimary),
  ];

  final List<_FavPlayer> _players = [
    _FavPlayer('Virat Kohli', 'India', '🇮🇳', 'Batter', '59.07 avg', AppColors.indiaOrange),
    _FavPlayer('Jasprit Bumrah', 'India', '🇮🇳', 'Bowler', '4.21 econ', AppColors.indiaBlue),
    _FavPlayer('Steve Smith', 'Australia', '🇦🇺', 'Batter', '62.8 avg', AppColors.australiaGold),
  ];

  final List<_FavSeries> _series = [
    _FavSeries('India vs Australia 2025', 'Test Series', AppColors.formatTest, '3 matches remaining'),
    _FavSeries('IPL 2025', 'T20 League', AppColors.formatT20, 'Starts in 12 days'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildTeamsTab(),
                  _buildPlayersTab(),
                  _buildSeriesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.screenCrimsonHeader, AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Heart icon tile
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.live, AppColors.liveDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AppColors.live.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Icon(
                Icons.favorite_rounded,
                color: Colors.white
                    .withOpacity(0.7 + _pulseAnim.value * 0.3),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAVOURITES',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                Text(
                  'Your saved teams, players & series',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Total count badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.live.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.live.withOpacity(0.22)),
            ),
            child: Text(
              '${_teams.length + _players.length + _series.length}',
              style: const TextStyle(
                color: AppColors.live,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withOpacity(0.06)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        padding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: AppColors.live,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.live.withOpacity(0.38),
              blurRadius: 10,
              spreadRadius: -2,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        tabs: [
          _buildTab('Teams', Icons.shield_rounded, _teams.length),
          _buildTab('Players', Icons.person_rounded, _players.length),
          _buildTab('Series', Icons.emoji_events_rounded, _series.length),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon, int count) {
    return Tab(
      height: 36,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700)),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    fontSize: 8, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Teams tab ─────────────────────────────────────────────────────────────

  Widget _buildTeamsTab() {
    if (_teams.isEmpty) return _buildEmptyState('teams', Icons.shield_outlined);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ..._teams.asMap().entries.map((e) {
          return FadeInUp(
            duration: Duration(milliseconds: 260 + e.key * 40),
            child: _TeamCard(
              team: e.value,
              pulseAnim: _pulseAnim,
              onRemove: () {
                HapticFeedback.mediumImpact();
                setState(() => _teams.removeAt(e.key));
              },
            ),
          );
        }),
        _buildDiscoverBanner('Discover more teams', Icons.shield_outlined),
      ],
    );
  }

  // ── Players tab ───────────────────────────────────────────────────────────

  Widget _buildPlayersTab() {
    if (_players.isEmpty)
      return _buildEmptyState('players', Icons.person_outlined);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ..._players.asMap().entries.map((e) {
          return FadeInUp(
            duration: Duration(milliseconds: 260 + e.key * 40),
            child: _PlayerCard(
              player: e.value,
              onRemove: () {
                HapticFeedback.mediumImpact();
                setState(() => _players.removeAt(e.key));
              },
            ),
          );
        }),
        _buildDiscoverBanner('Discover more players', Icons.person_outlined),
      ],
    );
  }

  // ── Series tab ────────────────────────────────────────────────────────────

  Widget _buildSeriesTab() {
    if (_series.isEmpty)
      return _buildEmptyState('series', Icons.emoji_events_outlined);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        ..._series.asMap().entries.map((e) {
          return FadeInUp(
            duration: Duration(milliseconds: 260 + e.key * 40),
            child: _SeriesCard(
              series: e.value,
              onRemove: () {
                HapticFeedback.mediumImpact();
                setState(() => _series.removeAt(e.key));
              },
            ),
          );
        }),
        _buildDiscoverBanner('Browse more series', Icons.emoji_events_outlined),
      ],
    );
  }

  // ── Discover banner ───────────────────────────────────────────────────────

  Widget _buildDiscoverBanner(String label, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: AppColors.textMuted, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String type, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated heart with pulse
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.live
                    .withOpacity(0.06 + _pulseAnim.value * 0.04),
                border: Border.all(
                  color: AppColors.live
                      .withOpacity(0.12 + _pulseAnim.value * 0.08),
                ),
              ),
              child: Icon(icon,
                  size: 38, color: AppColors.liveMuted),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            child: Text(
              'No favourite $type yet',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Tap the ♡ on any $type\nto add it here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.live, AppColors.liveDark],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.live.withOpacity(0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.explore_rounded,
                        color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Explore Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TEAM CARD ────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final _FavTeam team;
  final Animation<double> pulseAnim;
  final VoidCallback onRemove;

  const _TeamCard({
    required this.team,
    required this.pulseAnim,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: team.isLive
              ? AppColors.live.withOpacity(0.28)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Left accent
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      team.primaryColor,
                      team.accentColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Row(
                children: [
                  // Flag / emblem
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: team.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: team.primaryColor.withOpacity(0.28)),
                    ),
                    child: Center(
                      child: Text(team.flag,
                          style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                team.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (team.isLive) ...[
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: pulseAnim,
                                builder: (_, __) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.live.withOpacity(
                                      0.10 + pulseAnim.value * 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: AppColors.live.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppColors.live.withOpacity(
                                            0.6 + pulseAnim.value * 0.4,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: AppColors.live,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: team.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                team.code,
                                style: TextStyle(
                                  color: team.primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (team.score != null)
                              Text(
                                team.score!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Remove button
                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.live.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.live,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Live top stripe
            if (team.isLive)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.live, AppColors.liveAccent],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── PLAYER CARD ──────────────────────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final _FavPlayer player;
  final VoidCallback onRemove;

  const _PlayerCard({required this.player, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Left accent
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: player.color,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Row(
                children: [
                  // Avatar circle
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          player.color.withOpacity(0.3),
                          player.color.withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                          color: player.color.withOpacity(0.28)),
                    ),
                    child: Center(
                      child: Text(
                        player.name[0],
                        style: TextStyle(
                          color: player.color,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${player.flag} ${player.country}',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: player.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                player.role,
                                style: TextStyle(
                                  color: player.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              player.stat,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.live.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.live,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SERIES CARD ──────────────────────────────────────────────────────────────

class _SeriesCard extends StatelessWidget {
  final _FavSeries series;
  final VoidCallback onRemove;

  const _SeriesCard({required this.series, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: series.color,
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: series.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: series.color.withOpacity(0.25)),
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          series.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: series.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: series.color.withOpacity(0.25),
                                ),
                              ),
                              child: Text(
                                series.type,
                                style: TextStyle(
                                  color: series.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            Text(
                              series.status,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.live.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.live,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DATA MODELS ──────────────────────────────────────────────────────────────

class _FavTeam {
  final String name;
  final String flag;
  final String code;
  final Color primaryColor;
  final Color accentColor;
  final bool isLive;
  final String? score;

  const _FavTeam(
      this.name,
      this.flag,
      this.code,
      this.primaryColor,
      this.accentColor, {
        this.isLive = false,
        this.score,
      });
}

class _FavPlayer {
  final String name;
  final String country;
  final String flag;
  final String role;
  final String stat;
  final Color color;

  const _FavPlayer(
      this.name, this.country, this.flag, this.role, this.stat, this.color);
}

class _FavSeries {
  final String name;
  final String type;
  final Color color;
  final String status;

  const _FavSeries(this.name, this.type, this.color, this.status);
}
