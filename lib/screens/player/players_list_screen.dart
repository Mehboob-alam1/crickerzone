import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/player_provider.dart';
import '../../core/constants/colors.dart';
import '../../widgets/player_card.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedRole = 'all';

  static const _roles = [
    _Role('all',     'All',        Icons.grid_view_rounded,               AppColors.primary),
    _Role('batter',  'Batters',    Icons.sports_cricket_rounded,          Color(0xFF1565C0)),
    _Role('bowler',  'Bowlers',    Icons.sports_baseball_rounded,         Color(0xFFE53935)),
    _Role('allround','All-Round',  Icons.swap_horizontal_circle_rounded,  Color(0xFF2E7D32)),
    _Role('keeper',  'Keepers',    Icons.back_hand_rounded,               Color(0xFF6A1B9A)),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();

    _searchCtrl
        .addListener(() => setState(() => _query = _searchCtrl.text.trim().toLowerCase()));

    Future.delayed(Duration.zero, () {
      if (mounted) context.read<PlayerProvider>().fetchTrendingPlayers();
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List _filterPlayers(List players) {
    return players.where((p) {
      final name = (p.name as String? ?? '').toLowerCase();
      final role = (p.role as String? ?? '').toLowerCase();
      final matchesQuery = _query.isEmpty || name.contains(_query);
      final matchesRole = _selectedRole == 'all' ||
          role.contains(_selectedRole) ||
          (_selectedRole == 'allround' && role.contains('all'));
      return matchesQuery && matchesRole;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<PlayerProvider>(
          builder: (context, provider, _) {
            Future<void> onRefresh() =>
                provider.fetchTrendingPlayers(forceRefresh: true);

            // Loading
            if (provider.isLoading && provider.trendingPlayers.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, provider),
                  _buildSearchBar(),
                  _buildRoleChips(),
                  Expanded(child: _buildShimmer()),
                ],
              );
            }

            final filtered = _filterPlayers(provider.trendingPlayers);

            // Empty provider
            if (provider.trendingPlayers.isEmpty) {
              return Column(
                children: [
                  _buildHeader(context, provider),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onRefresh: onRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: _buildEmptyState(
                              'No players found',
                              'Pull to refresh',
                              Icons.person_search_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildHeader(context, provider),
                _buildSearchBar(),
                _buildRoleChips(),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: onRefresh,
                    child: filtered.isEmpty
                        ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 0.5,
                          child: _buildEmptyState(
                            'No players match',
                            'Try a different name or role',
                            Icons.search_off_rounded,
                          ),
                        ),
                      ],
                    )
                        : _buildList(filtered),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, PlayerProvider provider) {
    final total = provider.trendingPlayers.length;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 20, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1020), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 38,
              height: 38,
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
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'PLAYERS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'Featured & Trending',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (total > 0)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.22)),
              ),
              child: Text(
                '$total',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: _query.isNotEmpty
                ? AppColors.primary.withOpacity(0.28)
                : Colors.white.withOpacity(0.07),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded,
                color: _query.isNotEmpty
                    ? AppColors.primary
                    : AppColors.textMuted,
                size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search players…',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () => _searchCtrl.clear(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Role chips ────────────────────────────────────────────────────────────

  Widget _buildRoleChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _roles.map((r) {
          final sel = _selectedRole == r.key;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedRole = r.key);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: sel
                    ? r.color.withOpacity(0.14)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel
                      ? r.color.withOpacity(0.48)
                      : Colors.white.withOpacity(0.07),
                ),
                boxShadow: sel
                    ? [
                  BoxShadow(
                    color: r.color.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(r.icon,
                      size: 12,
                      color: sel ? r.color : AppColors.textMuted),
                  const SizedBox(width: 5),
                  Text(r.label,
                      style: TextStyle(
                        color: sel ? r.color : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight:
                        sel ? FontWeight.w700 : FontWeight.w500,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── List with top-3 podium ────────────────────────────────────────────────

  Widget _buildList(List players) {
    final hasEnoughForPodium = players.length >= 3 &&
        _query.isEmpty &&
        _selectedRole == 'all';

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Top-3 podium when no filters active
        if (hasEnoughForPodium) ...[
          FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: _TopThreePodium(players: players.take(3).toList()),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.trending_up_rounded,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'ALL PLAYERS',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${players.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Player cards
        ...players.asMap().entries.map((e) {
          return FadeInUp(
            duration: Duration(milliseconds: 250 + (e.key % 8) * 35),
            child: PlayerCard(player: e.value, index: e.key),
          );
        }),
      ],
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Podium shimmer
        AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) => Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: _shimmerGrad(_shimmerCtrl.value),
            ),
          ),
        ),
        ...List.generate(
          5,
              (_) => AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) => Container(
              height: 82,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _shimmerGrad(_shimmerCtrl.value),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _shimmerGrad(double v) => LinearGradient(
    colors: [
      AppColors.surface,
      AppColors.cardGrey.withOpacity(0.65 + v * 0.35),
      AppColors.surface,
    ],
    stops: [
      (v - 0.3).clamp(0.0, 1.0),
      v.clamp(0.0, 1.0),
      (v + 0.3).clamp(0.0, 1.0),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String title, String sub, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.07)),
            ),
            child: Icon(icon, size: 38, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(sub,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── TOP-3 PODIUM ─────────────────────────────────────────────────────────────

class _TopThreePodium extends StatelessWidget {
  final List players;
  const _TopThreePodium({required this.players});

  @override
  Widget build(BuildContext context) {
    // Layout: [2nd][1st][3rd]
    final ranks = [1, 0, 2]; // index into players list
    final medals  = ['🥈', '🥇', '🥉'];
    final heights = [76.0, 100.0, 60.0];
    final sizes   = [44.0, 58.0, 40.0];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.surface.withOpacity(0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.14)),
      ),
      child: Column(
        children: [
          Text(
            'TOP PLAYERS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(3, (i) {
              final playerIdx = ranks[i];
              final p = players[playerIdx];
              final medal = medals[i];
              final podiumH = heights[i];
              final avatarSz = sizes[i];
              final isFirst = i == 1;
              final name = (p.name as String? ?? 'Player').split(' ').last;
              final country = p.country as String? ?? '';
              final rating = p.rating?.toString() ?? '';

              return Expanded(
                child: Column(
                  children: [
                    Text(medal, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 6),
                    // Avatar
                    Container(
                      width: avatarSz,
                      height: avatarSz,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isFirst
                              ? [
                            const Color(0xFFFFD700),
                            const Color(0xFFFFA000),
                          ]
                              : [AppColors.surface, AppColors.cardGrey],
                        ),
                        border: Border.all(
                          color: isFirst
                              ? const Color(0xFFFFD700)
                              : AppColors.textMuted.withOpacity(0.30),
                          width: isFirst ? 2.5 : 1.5,
                        ),
                        boxShadow: isFirst
                            ? [
                          BoxShadow(
                            color: const Color(0xFFFFD700)
                                .withOpacity(0.30),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          (p.name as String? ?? '?')[0].toUpperCase(),
                          style: TextStyle(
                            color: isFirst
                                ? Colors.black
                                : Colors.white,
                            fontSize: isFirst ? 22 : 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isFirst ? 13 : 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (country.isNotEmpty)
                      Text(
                        country,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 9),
                      ),
                    if (rating.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        rating,
                        style: TextStyle(
                          color: isFirst
                              ? const Color(0xFFFFD700)
                              : AppColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Podium base
                    Container(
                      height: podiumH,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isFirst
                              ? [
                            const Color(0xFFFFD700).withOpacity(0.45),
                            const Color(0xFFFFD700).withOpacity(0.12),
                          ]
                              : [
                            AppColors.primary.withOpacity(0.22),
                            AppColors.primary.withOpacity(0.06),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8)),
                        border: Border.all(
                          color: isFirst
                              ? const Color(0xFFFFD700).withOpacity(0.30)
                              : AppColors.primary.withOpacity(0.16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '#${playerIdx + 1}',
                          style: TextStyle(
                            color: isFirst
                                ? const Color(0xFFFFD700)
                                : AppColors.primary,
                            fontSize: isFirst ? 18 : 14,
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
    );
  }
}

// ─── META ─────────────────────────────────────────────────────────────────────

class _Role {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _Role(this.key, this.label, this.icon, this.color);
}