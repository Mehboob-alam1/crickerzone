import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/match_card.dart';
import '../../widgets/schedule_match_card.dart';
import '../../core/constants/colors.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _tabs = [
    _TabItem('Schedule', Icons.calendar_month_rounded),
    _TabItem('Live', Icons.sensors_rounded),
    _TabItem('Upcoming', Icons.access_time_rounded),
    _TabItem('Recent', Icons.history_rounded),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().fetchMatchSchedules('international');
      context.read<MatchProvider>().fetchMatches();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF080C14),
        body: FadeTransition(
          opacity: _fadeCtrl,
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: Consumer<MatchProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading &&
                        provider.matchSchedules.isEmpty &&
                        provider.matches.isEmpty) {
                      return _buildLoader();
                    }
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildScheduleList(provider),
                        _buildMatchList(
                          provider.liveMatches,
                          'No live matches right now',
                          isLive: true,
                        ),
                        _buildMatchList(
                          provider.upcomingMatches,
                          'No upcoming matches scheduled',
                        ),
                        _buildMatchList(
                          provider.recentMatches,
                          'No recent matches found',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1520), Color(0xFF080C14)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Cricket icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.30)),
            ),
            child: const Center(
              child: Text('🏏', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MATCH CENTRE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  fontFamily: 'Rajdhani',
                ),
              ),
              Text(
                'International Cricket',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Live indicator
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Consumer<MatchProvider>(
              builder: (_, provider, __) {
                final liveCount = provider.liveMatches.length;
                if (liveCount == 0) return const SizedBox();
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935)
                        .withOpacity(0.12 + _pulseAnim.value * 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE53935)
                          .withOpacity(0.35 + _pulseAnim.value * 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withOpacity(
                              0.6 + _pulseAnim.value * 0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$liveCount LIVE',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE53935),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          // Filter icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF141C28),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1E2A3A)),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: AppColors.textSecondary,
              size: 18,
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
        color: const Color(0xFF0F1520),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A2234)),
      ),
      child: TabBar(
        controller: _tabController,
        padding: EdgeInsets.zero,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 12,
              spreadRadius: -2,
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        tabs: _tabs.map((t) {
          return Consumer<MatchProvider>(
            builder: (_, provider, __) {
              final isLiveTab = t.label == 'Live';
              final liveCount = provider.liveMatches.length;
              return Tab(
                height: 38,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      t.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (isLiveTab && liveCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$liveCount',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        }).toList(),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
      ),
    );
  }

  // ── Loader ────────────────────────────────────────────────────────────────

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading matches…',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Schedule list ─────────────────────────────────────────────────────────

  Widget _buildScheduleList(MatchProvider provider) {
    final schedules = provider.matchSchedules;
    if (schedules.isEmpty) {
      return _buildEmptyState(
        'No schedules found',
        Icons.calendar_today_outlined,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: const Color(0xFF0F1520),
      onRefresh: () =>
          provider.fetchMatchSchedules('international', forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final daySchedule = schedules[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              _DateHeader(date: daySchedule.date),
              ...daySchedule.seriesSchedules.expand((series) {
                return series.matches.map((match) => _EnhancedScheduleCard(
                  child: ScheduleMatchCard(
                      series: series, match: match),
                ));
              }),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  // ── Match list ────────────────────────────────────────────────────────────

  Widget _buildMatchList(
      List matches,
      String emptyMsg, {
        bool isLive = false,
      }) {
    if (matches.isEmpty) {
      return _buildEmptyState(
        emptyMsg,
        isLive
            ? Icons.sensors_rounded
            : Icons.event_note_outlined,
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: const Color(0xFF0F1520),
      onRefresh: () =>
          context.read<MatchProvider>().fetchMatches(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: matches.length,
        itemBuilder: (context, index) => _EnhancedMatchCard(
          child: MatchCard(match: matches[index]),
          isLive: isLive,
          index: index,
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String msg, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1520),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1A2234)),
            ),
            child: Icon(icon, size: 36, color: const Color(0xFF2A3550)),
          ),
          const SizedBox(height: 18),
          Text(
            msg,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pull to refresh',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DATE HEADER ──────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 16, 2, 10),
      child: Row(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today,
                    size: 12, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    Colors.transparent,
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

// ─── ENHANCED SCHEDULE CARD WRAPPER ──────────────────────────────────────────

class _EnhancedScheduleCard extends StatelessWidget {
  final Widget child;
  const _EnhancedScheduleCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1420),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A2234)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

// ─── ENHANCED MATCH CARD WRAPPER ─────────────────────────────────────────────

class _EnhancedMatchCard extends StatefulWidget {
  final Widget child;
  final bool isLive;
  final int index;
  const _EnhancedMatchCard({
    required this.child,
    required this.isLive,
    required this.index,
  });

  @override
  State<_EnhancedMatchCard> createState() => _EnhancedMatchCardState();
}

class _EnhancedMatchCardState extends State<_EnhancedMatchCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 40),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _opacityAnim = CurvedAnimation(
        parent: _slideCtrl, curve: Curves.easeOut);

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1420),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isLive
                  ? const Color(0xFFE53935).withOpacity(0.25)
                  : const Color(0xFF1A2234),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isLive
                    ? const Color(0xFFE53935).withOpacity(0.06)
                    : const Color(0x14000000),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                widget.child,
                // Live top accent line
                if (widget.isLive)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFE53935),
                            Color(0xFFFF7043),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TAB ITEM MODEL ───────────────────────────────────────────────────────────

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem(this.label, this.icon);
}