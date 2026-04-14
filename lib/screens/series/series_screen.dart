import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/constants/colors.dart';
import '../../providers/series_provider.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen>
    with TickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late AnimationController _fadeCtrl;

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';

  static const _filters = [
    _Filter('all',       'All',         Icons.grid_view_rounded,          AppColors.primary),
    _Filter('test',      'Test',        Icons.sports_cricket_rounded,      Color(0xFF8D1B2A)),
    _Filter('odi',       'ODI',         Icons.flag_rounded,                Color(0xFF1565C0)),
    _Filter('t20',       'T20',         Icons.bolt_rounded,                Color(0xFF6A1B9A)),
    _Filter('domestic',  'Domestic',    Icons.stadium_rounded,             Color(0xFF2E7D32)),
    _Filter('women',     'Women',       Icons.star_rounded,                Color(0xFFAD1457)),
  ];

  @override
  void initState() {
    super.initState();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });

    Future.microtask(() {
      if (mounted) context.read<SeriesProvider>().fetchInternationalSeries();
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List _filteredList(List all) {
    return all.where((s) {
      final name = (s.name as String? ?? '').toLowerCase();
      final type = (s.seriesType as String? ?? '').toLowerCase();

      final matchesSearch =
          _searchQuery.isEmpty || name.contains(_searchQuery);

      final matchesFilter = _selectedFilter == 'all' ||
          type.contains(_selectedFilter) ||
          name.contains(_selectedFilter);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: FadeTransition(
          opacity: _fadeCtrl,
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: Consumer<SeriesProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.seriesList.isEmpty) {
                      return _buildShimmer();
                    }

                    final list = _filteredList(provider.seriesList);

                    if (list.isEmpty) {
                      return _buildEmptyState(
                        provider.seriesList.isEmpty
                            ? 'No series found'
                            : 'No results for "$_searchQuery"',
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      onRefresh: () => provider.fetchInternationalSeries(
                          forceRefresh: true),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding:
                        const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final series = list[index];
                          return FadeInUp(
                            duration: Duration(
                                milliseconds: 260 + (index % 8) * 35),
                            child: _SeriesCard(
                              series: series,
                              index: index,
                              onTap: () {
                                // Navigate to series detail
                              },
                            ),
                          );
                        },
                      ),
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
          20, MediaQuery.of(context).padding.top + 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1200), AppColors.background],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: AppColors.textPrimary.withOpacity(0.08),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('🏏', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CRICKET SERIES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'International & Domestic',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<SeriesProvider>(
            builder: (_, provider, __) => Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.25)),
              ),
              child: Text(
                '${provider.seriesList.length} series',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded,
                color: AppColors.textMuted, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search series…',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
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

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filters.map((f) {
          final selected = _selectedFilter == f.key;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = f.key);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 0),
              decoration: BoxDecoration(
                color: selected
                    ? f.color.withOpacity(0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? f.color.withOpacity(0.50)
                      : AppColors.textPrimary.withOpacity(0.08),
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: f.color.withOpacity(0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f.icon,
                    size: 13,
                    color: selected ? f.color : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f.label,
                    style: TextStyle(
                      color: selected ? f.color : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: List.generate(
        7,
            (i) => AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) {
            final v = _shimmerCtrl.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.cardGrey.withOpacity(0.6 + v * 0.4),
                    AppColors.surface,
                  ],
                  stops: [
                    (v - 0.3).clamp(0.0, 1.0),
                    v.clamp(0.0, 1.0),
                    (v + 0.3).clamp(0.0, 1.0),
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

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState(String msg) {
    return Center(
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
            child: Icon(Icons.sports_cricket_outlined,
                size: 34, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(msg,
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(height: 6),
          Text('Pull down to refresh',
              style: TextStyle(
                  color: AppColors.textMuted.withOpacity(0.5),
                  fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── SERIES CARD ──────────────────────────────────────────────────────────────

class _SeriesCard extends StatelessWidget {
  final dynamic series;
  final int index;
  final VoidCallback onTap;

  const _SeriesCard({
    required this.series,
    required this.index,
    required this.onTap,
  });

  Color _typeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('test'))     return const Color(0xFF8D1B2A);
    if (t.contains('odi'))      return const Color(0xFF1565C0);
    if (t.contains('t20'))      return const Color(0xFF6A1B9A);
    if (t.contains('women'))    return const Color(0xFFAD1457);
    if (t.contains('domestic')) return const Color(0xFF2E7D32);
    return AppColors.primary;
  }

  String _typeEmoji(String type) {
    final t = type.toLowerCase();
    if (t.contains('test'))     return '🏴';
    if (t.contains('odi'))      return '🔵';
    if (t.contains('t20'))      return '⚡';
    if (t.contains('women'))    return '⭐';
    if (t.contains('domestic')) return '🏟️';
    return '🏏';
  }

  String _typeShort(String type) {
    final t = type.toLowerCase();
    if (t.contains('test'))          return 'TEST';
    if (t.contains('twenty20') ||
        t.contains('t20i'))          return 'T20I';
    if (t.contains('t20'))           return 'T20';
    if (t.contains('one day') ||
        t.contains('odi'))           return 'ODI';
    if (t.contains('women'))         return 'WOMEN';
    if (t.contains('domestic'))      return 'DOMESTIC';
    if (type.isNotEmpty)             return type.toUpperCase().substring(
        0, type.length > 8 ? 8 : type.length);
    return 'SERIES';
  }

  @override
  Widget build(BuildContext context) {
    final name = series.name as String? ?? 'Unknown Series';
    final type = series.seriesType as String? ?? '';
    final color = _typeColor(type);
    final emoji = _typeEmoji(type);
    final typeShort = _typeShort(type);

    // Parse date range if available
    final startDate = series.startDate as String?;
    final endDate = series.endDate as String?;
    final hasDates = startDate != null || endDate != null;

    // Number of matches if available
    final matchCount = series.numMatches as int?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textPrimary.withOpacity(0.06),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Left accent bar
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.3)],
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
                    // Format emoji badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: color.withOpacity(0.22)),
                      ),
                      child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Format pill
                              Container(
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius:
                                  BorderRadius.circular(5),
                                  border: Border.all(
                                      color:
                                      color.withOpacity(0.28)),
                                ),
                                child: Text(
                                  typeShort,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),

                              // Match count
                              if (matchCount != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardGrey,
                                    borderRadius:
                                    BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '$matchCount matches',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],

                              // Date range
                              if (hasDates) ...[
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    [
                                      if (startDate != null)
                                        startDate,
                                      if (endDate != null) endDate,
                                    ].join(' – '),
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 9,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Chevron
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: color,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── META ─────────────────────────────────────────────────────────────────────

class _Filter {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _Filter(this.key, this.label, this.icon, this.color);
}
