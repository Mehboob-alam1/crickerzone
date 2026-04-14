import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _RankingsScreenState extends State<RankingsScreen>
    with TickerProviderStateMixin {
  String _currentFormat = 'odi';
  late TabController _tabController;
  late AnimationController _shimmerCtrl;

  static const _formats = [
    _FormatItem('test', 'TEST', AppColors.formatTest),
    _FormatItem('odi', 'ODI', AppColors.formatOdi),
    _FormatItem('t20', 'T20', AppColors.formatT20),
  ];

  static const _tabs = [
    _TabMeta('TEAMS', Icons.shield_rounded),
    _TabMeta('BATTERS', Icons.sports_cricket_rounded),
    _TabMeta('BOWLERS', Icons.sports_baseball_rounded),
    _TabMeta('WTC', Icons.emoji_events_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RankingProvider>().fetchAllRankings(_currentFormat);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  void _changeFormat(String format) {
    if (format == _currentFormat) return;
    HapticFeedback.selectionClick();
    setState(() => _currentFormat = format);
    context.read<RankingProvider>().fetchAllRankings(format);
  }

  Future<void> _refresh() =>
      context.read<RankingProvider>().fetchAllRankings(_currentFormat, forceRefresh: true);

  Color get _formatColor {
    switch (_currentFormat) {
      case 'test': return AppColors.formatTest;
      case 't20':  return AppColors.formatT20;
      default:     return AppColors.formatOdi;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildHeader(),
            _buildFormatSelector(),
            _buildTabBar(),
            Expanded(
              child: Consumer<RankingProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return _buildSkeletonLoader();
                  }
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRankList(provider.teamRankings, isTeam: true),
                      _buildRankList(provider.batterRankings),
                      _buildRankList(provider.bowlerRankings),
                      _buildWtcStandings(provider.iccStandings),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _formatColor.withOpacity(0.18),
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // ICC logo tile
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _formatColor.withOpacity(0.4),
                  _formatColor.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                  color: _formatColor.withOpacity(0.35)),
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ICC RANKINGS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'Official World Rankings',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Refresh button
          GestureDetector(
            onTap: _refresh,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.textPrimary.withOpacity(0.08)),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Format selector ───────────────────────────────────────────────────────

  Widget _buildFormatSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: _formats.map((f) {
          final selected = f.key == _currentFormat;
          return Expanded(
            child: GestureDetector(
              onTap: () => _changeFormat(f.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.only(
                    right: f.key == _formats.last.key ? 0 : 8),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                    colors: [
                      f.color,
                      f.color.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: selected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? f.color.withOpacity(0.6)
                        : AppColors.textPrimary.withOpacity(0.07),
                  ),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: f.color.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  f.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
            color: AppColors.textPrimary.withOpacity(0.06)),
      ),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: _formatColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _formatColor.withOpacity(0.40),
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
        tabs: _tabs
            .map((t) => Tab(
          height: 36,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(t.icon, size: 13),
              const SizedBox(width: 5),
              Text(
                t.label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ),
    );
  }

  // ── Rank list ─────────────────────────────────────────────────────────────

  Widget _buildRankList(List<RankingModel> items, {bool isTeam = false}) {
    if (items.isEmpty) {
      return _buildEmptyState('No rankings available');
    }

    final top3 = items.take(3).toList();
    final rest = items.skip(3).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _refresh,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          // Podium for top 3
          _buildPodium(top3, isTeam: isTeam),
          const SizedBox(height: 16),

          // Rank 4+
          ...rest.asMap().entries.map((entry) {
            final index = entry.key + 3; // actual rank index
            final item = entry.value;
            return FadeInUp(
              duration: Duration(milliseconds: 280 + index * 30),
              child: _RankCard(
                item: item,
                index: index,
                formatColor: _formatColor,
                isTeam: isTeam,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Podium (top 3) ────────────────────────────────────────────────────────

  Widget _buildPodium(List<RankingModel> top3, {bool isTeam = false}) {
    if (top3.isEmpty) return const SizedBox();

    // Order: 2nd, 1st, 3rd for visual podium layout
    final ordered = [
      if (top3.length > 1) top3[1], // 2nd — left
      top3[0],                       // 1st — center
      if (top3.length > 2) top3[2], // 3rd — right
    ];
    final podiumHeights = top3.length > 2
        ? [88.0, 112.0, 72.0]
        : top3.length > 1
        ? [88.0, 112.0]
        : [112.0];
    final podiumRanks = top3.length > 2
        ? [2, 1, 3]
        : top3.length > 1
        ? [2, 1]
        : [1];

    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _formatColor.withOpacity(0.08),
              AppColors.surface.withOpacity(0.4),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _formatColor.withOpacity(0.14)),
        ),
        child: Column(
          children: [
            Text(
              'TOP RANKED',
              style: TextStyle(
                color: _formatColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(ordered.length, (i) {
                final item = ordered[i];
                final rank = podiumRanks[i];
                final height = podiumHeights[i];
                final isFirst = rank == 1;
                final medals = ['🥇', '🥈', '🥉'];
                final medalIdx = rank - 1;

                return Expanded(
                  child: Column(
                    children: [
                      // Medal
                      Text(
                        medalIdx < medals.length
                            ? medals[medalIdx]
                            : '$rank',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 6),

                      // Avatar / flag
                      Container(
                        width: isFirst ? 58 : 46,
                        height: isFirst ? 58 : 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isFirst
                                ? [
                              AppColors.gold,
                              AppColors.primary,
                            ]
                                : [
                              AppColors.surface,
                              AppColors.cardGrey,
                            ],
                          ),
                          border: Border.all(
                            color: isFirst
                                ? AppColors.gold
                                : AppColors.textPrimary.withOpacity(0.12),
                            width: isFirst ? 2.5 : 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: item.imageUrl != null
                              ? CachedNetworkImage(
                            imageUrl: item.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _FallbackAvatar(
                                    name: item.name ?? '?',
                                    color: _formatColor),
                          )
                              : _FallbackAvatar(
                              name: item.name ?? '?',
                              color: _formatColor),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Name
                      Text(
                        item.name ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isFirst ? 13 : 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (item.rating != null)
                        Text(
                          item.rating!,
                          style: TextStyle(
                            color: isFirst
                                ? AppColors.gold
                                : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Podium base
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isFirst
                                ? [
                              AppColors.gold.withOpacity(0.5),
                              AppColors.gold.withOpacity(0.15),
                            ]
                                : [
                              _formatColor.withOpacity(0.25),
                              _formatColor.withOpacity(0.08),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          border: Border.all(
                            color: isFirst
                                ? AppColors.gold.withOpacity(0.30)
                                : _formatColor.withOpacity(0.18),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              color: isFirst
                                  ? AppColors.gold
                                  : _formatColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── WTC Standings ─────────────────────────────────────────────────────────

  Widget _buildWtcStandings(Map<String, dynamic>? data) {
    if (data == null) {
      return _buildEmptyState('WTC standings unavailable');
    }

    final headers = (data['headers'] as List?)
        ?.map((e) => e.toString())
        .toList() ??
        [];
    final rows = (data['values'] as List?) ?? [];
    final subText = data['subText']?.toString() ?? '';

    if (headers.isEmpty || rows.isEmpty) {
      return _buildEmptyState('No WTC data available');
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _refresh,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // WTC header
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.formatTest, AppColors.formatTestDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.formatTest.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Text('🏟️', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'WORLD TEST CHAMPIONSHIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Current cycle standings',
                        style: TextStyle(
                          color: AppColors.wtcSubtitle,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Table
          FadeInUp(
            duration: const Duration(milliseconds: 450),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.textPrimary.withOpacity(0.07)),
              ),
              clipBehavior: Clip.hardEdge,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: Table(
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      // Header row
                      TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.cardGrey,
                        ),
                        children: headers.map((h) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            child: Text(
                              h,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.6,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Data rows
                      ...rows.asMap().entries.map((rowEntry) {
                        final rowIdx = rowEntry.key;
                        final row = rowEntry.value;
                        final cells = (row is Map && row['value'] is List)
                            ? (row['value'] as List)
                            .map((e) => e.toString())
                            .toList()
                            : <String>[];
                        final isTop2 = rowIdx < 2;

                        return TableRow(
                          decoration: BoxDecoration(
                            color: isTop2
                                ? AppColors.formatTest.withOpacity(0.08)
                                : rowIdx.isEven
                                ? AppColors.surface
                                : AppColors.background,
                          ),
                          children: cells.asMap().entries.map((cellEntry) {
                            final i = cellEntry.key;
                            final v = cellEntry.value;
                            final isImg =
                                i == 1 && int.tryParse(v) != null;

                            if (isImg) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: CachedNetworkImage(
                                  imageUrl:
                                  'https://static.cricbuzz.com/a/img/v1/i1/c$v/i.jpg',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) =>
                                  const SizedBox(width: 30, height: 30),
                                ),
                              );
                            }

                            // PCT column — highlight
                            final isPct = headers.length > i &&
                                headers[i].toLowerCase().contains('pct');
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 11),
                              child: Text(
                                v,
                                style: TextStyle(
                                  color: isPct
                                      ? (isTop2
                                      ? AppColors.gold
                                      : AppColors.textSecondary)
                                      : AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: isPct
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (subText.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.textPrimary.withOpacity(0.06)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subText,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String msg) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 360,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.textPrimary.withOpacity(0.08)),
                    ),
                    child: Icon(Icons.emoji_events_outlined,
                        size: 36, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Text(msg,
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('Pull to refresh',
                      style: TextStyle(
                          color: AppColors.textMuted.withOpacity(0.5),
                          fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Skeleton loader ───────────────────────────────────────────────────────

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        6,
            (i) => AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) {
            final shimmer = _shimmerCtrl.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.cardGrey.withOpacity(
                        0.5 + shimmer * 0.5),
                    AppColors.surface,
                  ],
                  stops: [
                    (shimmer - 0.3).clamp(0.0, 1.0),
                    shimmer.clamp(0.0, 1.0),
                    (shimmer + 0.3).clamp(0.0, 1.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── RANK CARD (position 4+) ──────────────────────────────────────────────────

class _RankCard extends StatelessWidget {
  final RankingModel item;
  final int index;
  final Color formatColor;
  final bool isTeam;

  const _RankCard({
    required this.item,
    required this.index,
    required this.formatColor,
    required this.isTeam,
  });

  @override
  Widget build(BuildContext context) {
    final rank = item.rank ?? (index + 1);
    final ratingVal = double.tryParse(item.rating ?? '') ?? 0;
    final maxRating = 900.0;
    final barFraction = (ratingVal / maxRating).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textPrimary.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '$rank',
              style: TextStyle(
                color: formatColor,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),

          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardGrey,
              border: Border.all(
                  color: formatColor.withOpacity(0.20)),
            ),
            child: ClipOval(
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                imageUrl: item.imageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _FallbackAvatar(
                    name: item.name ?? '?', color: formatColor),
              )
                  : _FallbackAvatar(
                  name: item.name ?? '?', color: formatColor),
            ),
          ),

          const SizedBox(width: 12),

          // Name + country + rating bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.country != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.country!,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (ratingVal > 0) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barFraction,
                      minHeight: 3,
                      backgroundColor:
                      AppColors.cardGrey,
                      valueColor:
                      AlwaysStoppedAnimation(formatColor),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Rating + points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.rating ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              if (item.points != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${item.points} pts',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── FALLBACK AVATAR ──────────────────────────────────────────────────────────

class _FallbackAvatar extends StatelessWidget {
  final String name;
  final Color color;
  const _FallbackAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.12),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ─── META MODELS ──────────────────────────────────────────────────────────────

class _FormatItem {
  final String key;
  final String label;
  final Color color;
  const _FormatItem(this.key, this.label, this.color);
}

class _TabMeta {
  final String label;
  final IconData icon;
  const _TabMeta(this.label, this.icon);
}
