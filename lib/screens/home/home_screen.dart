import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:score_zone/core/constants/colors.dart';
import 'package:score_zone/providers/match_provider.dart';
import 'package:score_zone/widgets/live_score_card.dart';
import 'package:score_zone/widgets/section_header.dart';
import 'package:score_zone/widgets/drawer_item.dart';
import 'package:score_zone/screens/player/players_list_screen.dart';
import 'package:score_zone/screens/team/teams_screen.dart';
import 'package:score_zone/screens/series/series_screen.dart';
import 'package:score_zone/screens/news/news_screen.dart';
import 'package:score_zone/screens/rankings/rankings_screen.dart';
import 'package:score_zone/screens/notifications/notifications_screen.dart';
import 'package:score_zone/screens/about/about_screen.dart';
import '../../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _fadeCtrl;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _loadData();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;
    await context.read<MatchProvider>().fetchMatches();
    if (!mounted) return;
    final p = context.read<MatchProvider>();
    if (p.matches.isEmpty && p.matchesLoadError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showErrorDialog(context, p.matchesLoadError!);
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.wifi_off_rounded,
                  color: AppColors.secondary, size: 18),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Data unavailable',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: _buildDrawer(),
        body: FadeTransition(
          opacity: _fadeCtrl,
          child: Consumer<MatchProvider>(
            builder: (context, provider, _) {
              final noMatchSections = provider.liveMatches.isEmpty &&
                  provider.upcomingMatches.isEmpty &&
                  provider.recentMatches.isEmpty;

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  await provider.fetchMatches(forceRefresh: true);
                  if (!context.mounted) return;
                  if (provider.matches.isEmpty &&
                      provider.matchesLoadError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        content: const Text('Could not refresh matches.',
                            style:
                            TextStyle(color: AppColors.textPrimary)),
                        action: SnackBarAction(
                          label: 'Details',
                          textColor: AppColors.primary,
                          onPressed: () => _showErrorDialog(
                              context, provider.matchesLoadError!),
                        ),
                      ),
                    );
                  }
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // ── Top bar ─────────────────────────────────────────
                    SliverToBoxAdapter(child: _buildTopBar(provider)),

                    // ── Search bar ──────────────────────────────────────
                    SliverToBoxAdapter(child: _buildSearchBar()),

                    // ── Quick access ────────────────────────────────────
                    SliverToBoxAdapter(child: _buildQuickAccess()),

                    // ── Main content ────────────────────────────────────
                    if (provider.isLoading && provider.matches.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ShimmerLoader(),
                      )
                    else if (noMatchSections)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _NoMatchesState(
                          hasError: provider.matchesLoadError != null,
                          onRetry: () =>
                              provider.fetchMatches(forceRefresh: true),
                          onShowError: provider.matchesLoadError == null
                              ? null
                              : () => _showErrorDialog(
                              context, provider.matchesLoadError!),
                        ),
                      )
                    else ...[
                        // Live matches
                        if (provider.liveMatches.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: FadeInLeft(
                              child: _SectionLabel(
                                title: 'Live Matches',
                                isLive: true,
                                count: provider.liveMatches.length,
                                pulseAnim: _pulseAnim,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: _buildLiveScroll(provider),
                          ),
                        ],

                        // Upcoming
                        if (provider.upcomingMatches.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: FadeInLeft(
                              delay: const Duration(milliseconds: 100),
                              child: _SectionLabel(
                                title: 'Upcoming Matches',
                                count: provider.upcomingMatches.length,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, i) => FadeInUp(
                                  delay: Duration(milliseconds: 60 * i),
                                  child: MatchCard(
                                      match:
                                      provider.upcomingMatches[i]),
                                ),
                                childCount:
                                provider.upcomingMatches.length,
                              ),
                            ),
                          ),
                        ],

                        // Recent
                        if (provider.recentMatches.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: FadeInLeft(
                              delay: const Duration(milliseconds: 200),
                              child: _SectionLabel(
                                title: 'Recent Matches',
                                count: provider.recentMatches.length,
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                    (context, i) => FadeInUp(
                                  delay: Duration(milliseconds: 60 * i),
                                  child: MatchCard(
                                      match:
                                      provider.recentMatches[i]),
                                ),
                                childCount:
                                provider.recentMatches.length,
                              ),
                            ),
                          ),
                        ],
                      ],

                    const SliverToBoxAdapter(
                        child: SizedBox(height: 40)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(MatchProvider provider) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0D00), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Menu button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                    color: Colors.white.withOpacity(0.07)),
              ),
              child: Icon(Icons.menu_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),

          const SizedBox(width: 12),

          // Logo + app name
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.sports_cricket_rounded,
                    color: Colors.black, size: 18),
              ),
              const SizedBox(width: 9),
              const Text(
                'SCORE ZONE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Live count pill
          if (provider.liveMatches.isNotEmpty)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935)
                      .withOpacity(0.10 + _pulseAnim.value * 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE53935)
                        .withOpacity(0.30 + _pulseAnim.value * 0.20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(
                            0.6 + _pulseAnim.value * 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${provider.liveMatches.length} LIVE',
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 8),

          // Notifications
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationsScreen()),
            ),
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.07)),
                  ),
                  child: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
                Positioned(
                  right: 9,
                  top: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: () => context.push('/search'),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border:
            Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 18),
              const SizedBox(width: 10),
              Text(
                'Search series, teams or players…',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '⌘ K',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick access grid ─────────────────────────────────────────────────────

  Widget _buildQuickAccess() {
    final categories = [
      _Cat('Series', Icons.emoji_events_rounded, const Color(0xFFFFA000),
              () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SeriesScreen()))),
      _Cat('Teams', Icons.shield_rounded, const Color(0xFF1565C0),
              () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TeamsScreen()))),
      _Cat('Players', Icons.person_rounded, const Color(0xFF6A1B9A),
              () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const PlayersListScreen()))),
      _Cat('Rankings', Icons.leaderboard_rounded, const Color(0xFF2E7D32),
              () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => const RankingsScreen()))),
      _Cat('News', Icons.newspaper_rounded, const Color(0xFFAD1457),
              () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NewsScreen()))),
      _Cat('About', Icons.info_outline_rounded, const Color(0xFF00695C),
              () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AboutScreen()))),
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Text(
              'QUICK ACCESS',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(
            height: 86,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (_, i) => _CatItem(cat: categories[i]),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  // ── Live match horizontal scroll ──────────────────────────────────────────

  Widget _buildLiveScroll(MatchProvider provider) {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: provider.liveMatches.length,
        itemBuilder: (_, i) {
          final match = provider.liveMatches[i];
          return FadeInRight(
            delay: Duration(milliseconds: 120 * i),
            child: LiveScoreCard(
              match: match,
              onTap: () => context.push('/match/${match.id}'),
            ),
          );
        },
      ),
    );
  }

  // ── Drawer ────────────────────────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      width: 280,
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C0E00), AppColors.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(color: Colors.white10),
              ),
            ),
            child: ZoomIn(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.40),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.sports_cricket_rounded,
                        color: Colors.black, size: 32),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'SCORE ZONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Live Cricket Updates',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerTile(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  color: AppColors.primary,
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerTile(
                  icon: Icons.emoji_events_rounded,
                  label: 'Series',
                  color: const Color(0xFFFFA000),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const SeriesScreen()));
                  },
                ),
                _DrawerTile(
                  icon: Icons.shield_rounded,
                  label: 'Teams',
                  color: const Color(0xFF1565C0),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const TeamsScreen()));
                  },
                ),
                _DrawerTile(
                  icon: Icons.person_rounded,
                  label: 'Players',
                  color: const Color(0xFF6A1B9A),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const PlayersListScreen()));
                  },
                ),
                _DrawerTile(
                  icon: Icons.leaderboard_rounded,
                  label: 'Rankings',
                  color: const Color(0xFF2E7D32),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const RankingsScreen()));
                  },
                ),
                _DrawerTile(
                  icon: Icons.newspaper_rounded,
                  label: 'News',
                  color: const Color(0xFFAD1457),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const NewsScreen()));
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Divider(
                      color: Colors.white.withOpacity(0.07), height: 1),
                ),

                _DrawerTile(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  color: AppColors.textMuted,
                  onTap: () => Navigator.pop(context),
                ),
                _DrawerTile(
                  icon: Icons.info_outline_rounded,
                  label: 'About Us',
                  color: const Color(0xFF00695C),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const AboutScreen()));
                  },
                ),
              ],
            ),
          ),

          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Text(
                  'v1.0.0',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
                const Spacer(),
                Text(
                  '© 2024 Score Zone',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SECTION LABEL ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  final bool isLive;
  final int count;
  final Animation<double>? pulseAnim;

  const _SectionLabel({
    required this.title,
    this.isLive = false,
    this.count = 0,
    this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          if (isLive && pulseAnim != null)
            AnimatedBuilder(
              animation: pulseAnim!,
              builder: (_, __) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935)
                      .withOpacity(0.6 + pulseAnim!.value * 0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935)
                          .withOpacity(0.4 + pulseAnim!.value * 0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              color: isLive ? const Color(0xFFE53935) : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: (isLive ? const Color(0xFFE53935) : AppColors.primary)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isLive
                    ? const Color(0xFFE53935)
                    : AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Spacer(),
          if (isLive)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                    const Color(0xFFE53935).withOpacity(0.25)),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── QUICK ACCESS CATEGORY ────────────────────────────────────────────────────

class _Cat {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Cat(this.label, this.icon, this.color, this.onTap);
}

class _CatItem extends StatelessWidget {
  final _Cat cat;
  const _CatItem({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        cat.onTap();
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: cat.color.withOpacity(0.20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(cat.icon, color: cat.color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              cat.label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ENHANCED DRAWER TILE ─────────────────────────────────────────────────────

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.color,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.25))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.18 : 0.09),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon,
                  color: isSelected ? color : AppColors.textSecondary,
                  size: 16),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── SHIMMER LOADER ───────────────────────────────────────────────────────────

class _ShimmerLoader extends StatefulWidget {
  const _ShimmerLoader();

  @override
  State<_ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<_ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal shimmer strip (for live)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => _shimmerBox(height: 16, width: 120),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (_, i) => AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Container(
                width: 240,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: _shimmerGradient(_ctrl.value),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(
          4,
              (i) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Container(
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _shimmerGradient(_ctrl.value),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox({required double height, double? width}) =>
      Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: _shimmerGradient(_ctrl.value),
        ),
      );

  LinearGradient _shimmerGradient(double v) => LinearGradient(
    colors: [
      AppColors.surface,
      AppColors.cardGrey.withOpacity(0.7 + v * 0.3),
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
}

// ─── NO MATCHES STATE ─────────────────────────────────────────────────────────

class _NoMatchesState extends StatelessWidget {
  final bool hasError;
  final VoidCallback onRetry;
  final VoidCallback? onShowError;

  const _NoMatchesState({
    required this.hasError,
    required this.onRetry,
    this.onShowError,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.07)),
            ),
            child: Icon(
              hasError
                  ? Icons.cloud_off_rounded
                  : Icons.event_busy_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasError
                ? 'Unable to load matches'
                : 'No matches right now',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasError
                ? 'Check your connection and try again.'
                : 'Pull down to refresh or try searching.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB300), AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.refresh_rounded,
                      color: Colors.black, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onShowError != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onShowError,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'View error details',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
}